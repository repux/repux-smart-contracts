const FeeStakes = artifacts.require('./FeeStakes.sol');
const FeeStakesStorage = artifacts.require('./FeeStakesStorage.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('FeeStakes', (accounts) => {
    let feeStakes,
        feeStakesAddress,
        feeStakesStorage
    ;

    const currentFeeAdmin = accounts[1];
    const newFeeAdmin = accounts[2];
    const flatFee = 2;
    const newFlatFee = 3;
    const percentageFee = 3;

    before(async () => {
        feeStakesStorage = await FeeStakesStorage.deployed();
        feeStakesAddress = await feeStakesStorage.getCurrentFeeStakesAddress();
        feeStakes = await FeeStakes.at(feeStakesAddress);

        await feeStakes.proposeNewFeeAdmin(currentFeeAdmin);
        await feeStakes.acceptFeeAdminTransfer({ from: currentFeeAdmin });
    });

    it('should not be able to set fees as owner', async () => {
        expectThrow(feeStakes.setFileFlatFee(flatFee));
        expectThrow(feeStakes.setFileStorageFee(flatFee));
        expectThrow(feeStakes.setOrderFlatFee(flatFee));
        expectThrow(feeStakes.setOrderPercentageFee(percentageFee));
        expectThrow(feeStakes.setDeveloperFlatFee(flatFee));
        expectThrow(feeStakes.setDeveloperPercentageFee(percentageFee));

        (await feeStakes.getFileFlatFee.call()).toNumber().should.equal(0);
        (await feeStakes.getFileStorageFee.call()).toNumber().should.equal(0);
        (await feeStakes.getOrderFlatFee.call()).toNumber().should.equal(0);
        (await feeStakes.getOrderPercentageFee.call()).toNumber().should.equal(0);
        (await feeStakes.getDeveloperFlatFee.call()).toNumber().should.equal(0);
        (await feeStakes.getDeveloperPercentageFee.call()).toNumber().should.equal(0);
    });

    it('should be able to set fees as admin', async () => {
        await feeStakes.setFileFlatFee(flatFee, { from: currentFeeAdmin });
        await feeStakes.setFileStorageFee(flatFee, { from: currentFeeAdmin });
        await feeStakes.setOrderFlatFee(flatFee, { from: currentFeeAdmin });
        await feeStakes.setOrderPercentageFee(percentageFee, { from: currentFeeAdmin });
        await feeStakes.setDeveloperFlatFee(flatFee, { from: currentFeeAdmin });
        await feeStakes.setDeveloperPercentageFee(percentageFee, { from: currentFeeAdmin });

        (await feeStakes.getFileFlatFee.call()).toNumber().should.equal(flatFee);
        (await feeStakes.getFileStorageFee.call()).toNumber().should.equal(flatFee);
        (await feeStakes.getOrderFlatFee.call()).toNumber().should.equal(flatFee);
        (await feeStakes.getOrderPercentageFee.call()).toNumber().should.equal(percentageFee);
        (await feeStakes.getDeveloperFlatFee.call()).toNumber().should.equal(flatFee);
        (await feeStakes.getDeveloperPercentageFee.call()).toNumber().should.equal(percentageFee);
    });

    it('should be able to set new admin', async () => {
        await feeStakes.proposeNewFeeAdmin(newFeeAdmin);
        await feeStakes.acceptFeeAdminTransfer({ from: newFeeAdmin });

        expectThrow(feeStakes.setFileFlatFee(flatFee, { from: currentFeeAdmin }));

        await feeStakes.setFileFlatFee(newFlatFee, { from: newFeeAdmin });

        (await feeStakes.getFileFlatFee.call()).toNumber().should.equal(newFlatFee);
    });
});
