const DataProduct = artifacts.require('./DataProduct.sol');
const Registry = artifacts.require('./Registry.sol');
const RepuX = artifacts.require('./DemoToken.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('DataProduct', (accounts) => {
    let registry, repux, sellerBalance, fee;

    const seller = accounts[0];
    const firstBuyer = accounts[1];
    const secondBuyer = accounts[2];
    const buyerBalance = 1000000;
    const price = 123;
    const toLowPrice = 2;
    const flatFee = 2;
    const percentageFee = 3;
    const sellerMetaHash = 'sellerMetaHash';
    const publicKey = 'publicKey';
    const buyerMetaHash = 'buyerMetaHash';

    before(async () => {
        registry = await Registry.deployed();
        repux = await RepuX.deployed();
        sellerBalance = (await repux.balanceOf.call(seller)).toNumber();

        repux.issue(firstBuyer, buyerBalance);

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal(buyerBalance);

        await registry.proposeNewFeeAdmin(seller);
        await registry.acceptFeeAdminTransfer();

        await registry.setTransactionFlatFee(flatFee);
        await registry.setTransactionPercentageFee(percentageFee);

        fee = (await registry.getTransactionFee.call(price)).toNumber();
    });

    it('should go through the whole purchase flow', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });

        (await repux.allowance.call(firstBuyer, dataProduct.address)).toNumber().should.equal(price);

        await dataProduct.purchase(publicKey, { from: firstBuyer });

        (await dataProduct.buyersDeposit.call()).toNumber().should.equal((price - fee));
        (await registry.feesDeposit.call()).toNumber().should.equal(fee);

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal((price - fee));
        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(fee);
        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - price));

        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
        data[1].should.equal(buyerMetaHash);
        data[3].should.equal(true, 'Is purchased');
        data[4].should.equal(true, 'Is finalised');
        (await dataProduct.buyersDeposit.call()).toNumber().should.equal(0);
        (await registry.feesDeposit.call()).toNumber().should.equal(0);

        await dataProduct.withdraw();

        (await repux.allowance.call(firstBuyer, dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price - fee));

        await registry.withdraw();

        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price));
    });

    it('should forbid withdraw of unfinalised transaction', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
        data[3].should.equal(true, 'Is purchased');
        data[4].should.equal(false, 'Is finalised');

        expectThrow(dataProduct.withdraw());

        (await repux.allowance.call(firstBuyer, dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal((price - fee));
        (await repux.balanceOf.call(seller)).toNumber().should.equal(sellerBalance);

        expectThrow(registry.withdraw());

        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(fee);
    });

    it('should forbid purchasing of disabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        await dataProduct.approve(firstBuyer, buyerMetaHash);

        await dataProduct.disable();

        (await dataProduct.disabled.call()).should.equal(true);

        expectThrow(dataProduct.purchase(publicKey, { from: secondBuyer }));

        await dataProduct.withdraw();

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + 2 * (price - fee)));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
    });

    it('should forbid killing of enabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.kill());

        (await dataProduct.disabled.call()).should.equal(false);
    });

    it('should forbid killing of holding funds data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.kill());

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal((price - fee));
    });

    it('should allow to kill disabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await dataProduct.disable();

        await dataProduct.kill();

        expectThrow(dataProduct.purchase(publicKey, { from: firstBuyer }));

        (await dataProduct.disabled.call()).should.equal(true);
    });

    it('should not be possible to set price lower than transaction fee', async () => {
        expectThrow(registry.createDataProduct(sellerMetaHash, toLowPrice));

        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.setPrice(toLowPrice));

        (await dataProduct.price.call()).toNumber().should.equal(price);
    });
});
