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
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });

        (await repux.allowance.call(firstBuyer, dataProduct.address)).toNumber().should.equal(price);

        await dataProduct.purchase(publicKey, { from: firstBuyer });

        (await dataProduct.buyersDeposit.call()).toNumber().should.equal(price);

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(price);
        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - price));

        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
        data[1].should.equal(buyerMetaHash);
        data[4].toNumber().should.equal(fee);
        data[5].should.equal(true, 'Is purchased');
        data[6].should.equal(true, 'Is finalised');
        (await dataProduct.buyersDeposit.call()).toNumber().should.equal(0);
        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(fee);

        await dataProduct.withdraw();

        (await repux.allowance.call(firstBuyer, dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price - fee));

        await registry.withdraw();

        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + price));
    });

    it('should forbid purchase twice by same buyer', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        expectThrow(dataProduct.purchase(publicKey, { from: firstBuyer }));

        (await dataProduct.buyersDeposit.call()).toNumber().should.equal(price);
        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (2 * price)));
    });

    it('should forbid withdraw of unfinalised transaction', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[6].should.equal(false, 'Is finalised');

        expectThrow(dataProduct.withdraw());
        expectThrow(registry.withdraw());

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(price);
        (await repux.balanceOf.call(registry.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal(sellerBalance);
    });

    it('should forbid purchasing of disabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        await dataProduct.disable();

        (await dataProduct.disabled.call()).should.equal(true);

        expectThrow(dataProduct.purchase(publicKey, { from: secondBuyer }));

        await dataProduct.withdraw();

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(0);
        (await repux.balanceOf.call(seller)).toNumber().should.equal((sellerBalance + 2 * (price - fee)));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
    });

    it('should forbid purchasing data product with kyc enabled by non-kyc buyer', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);
        await dataProduct.setKyc(true);

        expectThrow(dataProduct.purchase(publicKey, { from: firstBuyer }));
        (await dataProduct.kyc.call()).should.equal(true);
    });

    it('should allow purchasing data product with kyc enabled by kyc buyer', async () => {
        await registry.setIdentifiedCustomer(firstBuyer, true);

        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);
        await dataProduct.setKyc(true);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(price);
    });

    it('should forbid killing of enabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.kill());

        (await dataProduct.disabled.call()).should.equal(false);
    });

    it('should forbid killing of holding funds data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.kill());

        (await repux.balanceOf.call(dataProduct.address)).toNumber().should.equal(price);
    });

    it('should allow to kill disabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await dataProduct.disable();

        await dataProduct.kill();

        expectThrow(dataProduct.purchase(publicKey, { from: firstBuyer }));

        (await dataProduct.disabled.call()).should.equal(true);
    });

    it('should not be possible to set price lower than transaction fee', async () => {
        expectThrow(registry.createDataProduct(sellerMetaHash, toLowPrice, 2));

        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.setPrice(toLowPrice));

        (await dataProduct.price.call()).toNumber().should.equal(price);
    });

    it('should not be possible to cancel transaction before delivery deadline', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.cancelPurchase({ from: firstBuyer }));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal(publicKey);
        data[2].toNumber().should.be.above(Math.floor(new Date().getTime() / 1000));
    });

    it('should not be possible to cancel transaction after finalisation', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[6].should.equal(true, 'Is finalised');

        expectThrow(dataProduct.cancelPurchase({ from: firstBuyer }));

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (8 * price)));
    });

    it('should not be possible to cancel transaction by someone else than buyer', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 0);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.cancelPurchase({ from: seller }));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[5].should.equal(true, 'Is purchased');
    });

    it('should be possible to cancel transaction after delivery deadline', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 0);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (10 * price)));

        await dataProduct.cancelPurchase({ from: firstBuyer });

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (9 * price)));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[0].should.equal('');
    });

    it('should not be possible to rate unfinalised transaction', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.rate(5, { from: firstBuyer }));

        const data = await dataProduct.getTransactionData.call(firstBuyer);
        data[6].should.equal(false, 'Is finalised');
        data[7].should.equal(false, 'Is rated');
    });
});
