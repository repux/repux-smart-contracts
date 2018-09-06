const DataProduct = artifacts.require('./DataProduct.sol');
const FeeStakes = artifacts.require('./FeeStakes.sol');
const FeeStakesStorage = artifacts.require('./FeeStakesStorage.sol');
const Registry = artifacts.require('./Registry.sol');
const RegistryStorage = artifacts.require('./RegistryStorage.sol');
const RepuX = artifacts.require('./DemoToken.sol');
const Order = artifacts.require('./Order.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('DataProduct', (accounts) => {
    let fee,
        feeStakes,
        feeStakesAddress,
        feeStakesStorage,
        registry,
        registryAddress,
        registryStorage,
        repux,
        sellerBalance
    ;

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
        feeStakesStorage = await FeeStakesStorage.deployed();
        feeStakesAddress = await feeStakesStorage.getCurrentFeeStakesAddress();
        feeStakes = await FeeStakes.at(feeStakesAddress);
        registryStorage = await RegistryStorage.deployed();
        registryAddress = await registryStorage.getCurrentRegistryAddress();
        registry = await Registry.at(registryAddress);
        repux = await RepuX.deployed();
        sellerBalance = (await repux.balanceOf.call(seller)).toNumber();

        await repux.issue(firstBuyer, buyerBalance);

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal(buyerBalance);

        await feeStakes.proposeNewFeeAdmin(seller);
        await feeStakes.acceptFeeAdminTransfer();

        await feeStakes.setOrderFlatFee(flatFee);
        await feeStakes.setOrderPercentageFee(percentageFee);

        fee = (await feeStakes.getOrderFee.call(price)).toNumber();
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

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.buyerPublicKey.call()).should.equal(publicKey);
        (await order.buyerMetaHash.call()).should.equal(buyerMetaHash);
        (await order.fee.call()).toNumber().should.equal(fee);
        (await order.purchased.call()).should.equal(true);
        (await order.finalised.call()).should.equal(true);

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

    it('should forbid withdraw of unfinalised order', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.finalised.call()).should.equal(false);

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

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.buyerPublicKey.call()).should.equal(publicKey);
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

    it('should not be possible to set price lower than order fee', async () => {
        expectThrow(registry.createDataProduct(sellerMetaHash, toLowPrice, 2));

        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.setPrice(toLowPrice));

        (await dataProduct.price.call()).toNumber().should.equal(price);
    });

    it('should not be possible to cancel order before purchasing data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        expectThrow(dataProduct.cancelPurchase({ from: firstBuyer }));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        parseInt(orderAddress).should.equal(0);
    });

    it('should not be possible to cancel order before delivery deadline', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.cancelPurchase({ from: firstBuyer }));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.buyerPublicKey.call()).should.equal(publicKey);
        (await order.deliveryDeadline.call()).toNumber().should.be.above(Math.floor(new Date().getTime() / 1000));
    });

    it('should not be possible to cancel order after finalisation', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.finalised.call()).should.equal(true);

        expectThrow(dataProduct.cancelPurchase({ from: firstBuyer }));

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (8 * price)));
    });

    it('should not be possible to cancel order by someone else than buyer', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 0);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.cancelPurchase({ from: seller }));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.purchased.call()).should.equal(true);
    });

    it('should be possible to cancel order after delivery deadline', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 0);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (10 * price)));

        await dataProduct.cancelPurchase({ from: firstBuyer });

        (await repux.balanceOf.call(firstBuyer)).toNumber().should.equal((buyerBalance - (9 * price)));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        parseInt(orderAddress).should.equal(0);
    });

    it('should be possible to cancel order of disabled data product', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        await dataProduct.disable();

        (await dataProduct.disabled.call()).should.equal(true);

        await dataProduct.cancelPurchase({ from: firstBuyer });

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        parseInt(orderAddress).should.equal(0);
    });

    it('should not be possible to rate unfinalised order', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });

        expectThrow(dataProduct.rate(5, { from: firstBuyer }));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.finalised.call()).should.equal(false);
        (await order.rated.call()).should.equal(false);
    });

    it('should not be possible to rate order twice', async () => {
        const dataProductTx = await registry.createDataProduct(sellerMetaHash, price, 2);
        const dataProduct = DataProduct.at(dataProductTx.logs[0].args.dataProduct);

        await repux.approve(dataProduct.address, price, { from: firstBuyer });
        await dataProduct.purchase(publicKey, { from: firstBuyer });
        await dataProduct.finalise(firstBuyer, buyerMetaHash);

        await dataProduct.rate(5, { from: firstBuyer });
        expectThrow(dataProduct.rate(5, { from: firstBuyer }));

        const orderAddress = await dataProduct.getOrder.call({ from: firstBuyer });
        const order = Order.at(orderAddress);

        (await order.finalised.call()).should.equal(true);
        (await order.rated.call()).should.equal(true);
    });
});
