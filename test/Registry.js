const Registry = artifacts.require('./Registry.sol');
const RegistryFactory = artifacts.require('./RegistryFactory.sol');
const RegistryStorage = artifacts.require('./RegistryStorage.sol');
const RepuX = artifacts.require('./DemoToken.sol');

const sha3 = require('solidity-sha3').default;
const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('Registry', (accounts) => {
    let registry, registryAddress, registryFactory, registryStorage, repux;

    const currentFeeAdmin = accounts[1];
    const newFeeAdmin = accounts[2];
    const flatFee = 2;
    const newFlatFee = 3;
    const percentageFee = 3;

    before(async () => {
        registryFactory = await RegistryFactory.deployed();
        registryStorage = await RegistryStorage.deployed();
        registryAddress = await registryStorage.getCurrentRegistryAddress();
        registry = await Registry.at(registryAddress);
        repux = await RepuX.deployed();

        await registry.proposeNewFeeAdmin(currentFeeAdmin);
        await registry.acceptFeeAdminTransfer({ from: currentFeeAdmin });
    });

    it('should not be able to set fees as owner', async () => {
        expectThrow(registry.setFileFlatFee(flatFee));
        expectThrow(registry.setFileStorageFee(flatFee));
        expectThrow(registry.setOrderFlatFee(flatFee));
        expectThrow(registry.setOrderPercentageFee(percentageFee));
        expectThrow(registry.setDeveloperFlatFee(flatFee));
        expectThrow(registry.setDeveloperPercentageFee(percentageFee));

        (await registry.fileFlatFee.call()).toNumber().should.equal(0);
        (await registry.fileStorageFee.call()).toNumber().should.equal(0);
        (await registry.orderFlatFee.call()).toNumber().should.equal(0);
        (await registry.orderPercentageFee.call()).toNumber().should.equal(0);
        (await registry.developerFlatFee.call()).toNumber().should.equal(0);
        (await registry.developerPercentageFee.call()).toNumber().should.equal(0);
    });

    it('should be able to set fees as admin', async () => {
        await registry.setFileFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setFileStorageFee(flatFee, { from: currentFeeAdmin });
        await registry.setOrderFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setOrderPercentageFee(percentageFee, { from: currentFeeAdmin });
        await registry.setDeveloperFlatFee(flatFee, { from: currentFeeAdmin });
        await registry.setDeveloperPercentageFee(percentageFee, { from: currentFeeAdmin });

        (await registry.fileFlatFee.call()).toNumber().should.equal(flatFee);
        (await registry.fileStorageFee.call()).toNumber().should.equal(flatFee);
        (await registry.orderFlatFee.call()).toNumber().should.equal(flatFee);
        (await registry.orderPercentageFee.call()).toNumber().should.equal(percentageFee);
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

    it('should not be able to create another Registry contract', async () => {
        expectThrow(registryFactory.createRegistry(
            '0x635372c24d44deda922267ef0d6c706900221ba39c758d685964b3deca73608e',
            '0x635372c24d44deda922267ef0d6c706900221ba39c758d685964b3deca73608e',
            '0x635372c24d44deda922267ef0d6c706900221ba39c758d685964b3deca73608e',
            '0x635372c24d44deda922267ef0d6c706900221ba39c758d685964b3deca73608e'
        ));

        (await registryFactory.created.call()).should.equal(true);
    });

    it('should not have privileges to Storage contract', async () => {
        const factoryPrivilege = await registryStorage.getAddress(sha3('contract.address', registryFactory.address));

        parseInt(factoryPrivilege).should.equal(0);
    });
});
