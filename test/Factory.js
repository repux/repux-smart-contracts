const RegistryFactory = artifacts.require('./RegistryFactory.sol');
const RegistryStorage = artifacts.require('./RegistryStorage.sol');

const sha3 = require('solidity-sha3').default;
const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('Factory', (accounts) => {
    let registryFactory,
        registryStorage
    ;

    before(async () => {
        registryFactory = await RegistryFactory.deployed();
        registryStorage = await RegistryStorage.deployed();
    });

    it('should not be able to create another Registry contract', async () => {
        expectThrow(registryFactory.createRegistry(
            '0x635372c24d44deda922267ef0d6c706900221ba39c758d685964b3deca73608e',
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
