const Registry = artifacts.require('./Registry.sol');
const RepuX = artifacts.require('./DemoToken.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('Registry', (accounts) => {
    let registry, repux;

    const currentFeeAdmin = accounts[1];
    const newFeeAdmin = accounts[2];
    const flatFee = 2;
    const newFlatFee = 3;
    const percentageFee = 3;

    before(async () => {
        registry = await Registry.deployed();
        repux = await RepuX.deployed();

        await registry.proposeNewFeeAdmin(currentFeeAdmin);
        await registry.acceptFeeAdminTransfer({ from: currentFeeAdmin });
    });

    it('should not be able to set fees as owner', async () => {
        expectThrow(registry.setFileFlatFee(flatFee));
        expectThrow(registry.setFileStorageFee(flatFee));
        expectThrow(registry.setTransactionFlatFee(flatFee));
        expectThrow(registry.setTransactionPercentageFee(percentageFee));
        expectThrow(registry.setDeveloperFlatFee(flatFee));
        expectThrow(registry.setDeveloperPercentageFee(percentageFee));

        (await registry.fileFlatFee.call()).toNumber().should.equal(0);
        (await registry.fileStorageFee.call()).toNumber().should.equal(0);
        (await registry.transactionFlatFee.call()).toNumber().should.equal(0);
        (await registry.transactionPercentageFee.call()).toNumber().should.equal(0);
        (await registry.developerFlatFee.call()).toNumber().should.equal(0);
        (await registry.developerPercentageFee.call()).toNumber().should.equal(0);
    });

    it('should be able to set fees as admin', async () => {
        await registry.setFileFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setFileStorageFee(flatFee, { from: currentFeeAdmin });
        await registry.setTransactionFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setTransactionPercentageFee(percentageFee, { from: currentFeeAdmin });
        await registry.setDeveloperFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setDeveloperPercentageFee(percentageFee, { from: currentFeeAdmin });

        (await registry.fileFlatFee.call()).toNumber().should.equal(flatFee);
        (await registry.fileStorageFee.call()).toNumber().should.equal(flatFee);
        (await registry.transactionFlatFee.call()).toNumber().should.equal(flatFee);
        (await registry.transactionPercentageFee.call()).toNumber().should.equal(percentageFee);
        (await registry.developerFlatFee.call()).toNumber().should.equal(flatFee);
        (await registry.developerPercentageFee.call()).toNumber().should.equal(percentageFee);
    });

    it('should be able to set new admin', async () => {
        await registry.proposeNewFeeAdmin(newFeeAdmin);
        await registry.acceptFeeAdminTransfer({ from: newFeeAdmin });

        expectThrow(registry.setFileFlatFee(flatFee, { from: currentFeeAdmin }));

        await registry.setFileFlatFee(newFlatFee, { from: newFeeAdmin });

        (await registry.fileFlatFee.call()).toNumber().should.equal(newFlatFee);
    });
});
