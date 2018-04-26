const DataProduct = artifacts.require('./DataProduct.sol');
const Registry = artifacts.require('./Registry.sol');
const RepuX = artifacts.require('./DemoToken.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('DataProduct', (accounts) => {
    let registry, repux, sellerBalance, fee;

    const seller = accounts[0];
    const buyer = accounts[1];
    const buyerBalance = 1000000;
    const price = 123;
    const toLowPrice = 2;
    const flatFee = 2;
    const percentageFee = 3;
    const sellerMetaHash = 'sellerMetaHash';
    const publicKey = 'publicKey';
    const secret = 'encryptedSecret';
    const buyerMetaHash = 'buyerMetaHash';

    before(async () => {
        registry = await Registry.deployed();
        repux = await RepuX.deployed();
        sellerBalance = (await repux.balanceOf.call(seller)).toNumber();

        repux.issue(buyer, buyerBalance);

        (await repux.balanceOf.call(buyer)).toNumber().should.equal(buyerBalance);

        await registry.proposeNewFeeAdmin(seller);
        await registry.acceptFeeAdminTransfer();

        await registry.setTransactionFlatFee(flatFee);
        await registry.setTransactionPercentageFee(percentageFee);

        fee = (await registry.getTransactionFee.call(price)).toNumber();
    });

    it('should go through the whole purchase flow', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: buyer });

        (await repux.allowance.call(buyer, dataProduct.address)).toNumber().should.equal(price);

        await dataProduct.purchase(publicKey, { from: buyer });

        (await dataProduct.buyersDeposit.call()).toNumber().should.equal((price - fee));
        (await registry.feesDeposit.call()).toNumber().should.equal(fee);

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal((price - fee));
        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(fee);
        (await repux.balanceOf.call(buyer)).toNumber().should.equal((buyerBalance - price));

        await dataProduct.approve(buyer, secret, buyerMetaHash);

        const data = await dataProduct.getTransactionData.call(buyer);
        data[0].should.equal(publicKey);
        data[1].should.equal(secret);
        data[2].should.equal(buyerMetaHash);
        data[4].should.equal(true, 'Is purchased');
        data[5].should.equal(true, 'Is approved');
        (await dataProduct.buyersDeposit.call()).toNumber().should.equal(0);
        (await registry.feesDeposit.call()).toNumber().should.equal(0);

        await dataProduct.withdraw();

        (await repux.allowance.call(buyer, dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price - fee));

        await registry.withdraw();

        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price));
    });

    it('should forbid withdraw of unapproved transaction', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: buyer });
        await dataProduct.purchase(publicKey, { from: buyer });

        const data = await dataProduct.getTransactionData.call(buyer);
        data[0].should.equal(publicKey);
        data[4].should.equal(true, 'Is purchased');
        data[5].should.equal(false, 'Is approved');

        expectThrow(dataProduct.withdraw());

        (await repux.allowance.call(buyer, dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal((price - fee));
        (await repux.balanceOf.call(seller)).toNumber().should.equal(sellerBalance);

        expectThrow(registry.withdraw());

        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(fee);
    });

    it('should not be possible to set price lower than transaction fee', async () => {
        expectThrow(registry.createDataProduct(sellerMetaHash, toLowPrice));

        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.setPrice(toLowPrice));

        (await dataProduct.price.call()).toNumber().should.equal(price);
    });
});
