const AddressArrayRemover = artifacts.require('./utils/AddressArrayRemover.sol');
const DataProductFactory = artifacts.require('./DataProductFactory.sol');
const DemoToken = artifacts.require('./DemoToken.sol');
const FeeStakesFactory = artifacts.require('./FeeStakesFactory.sol');
const FeeStakesStorage = artifacts.require('./FeeStakesStorage.sol');
const OrderFactory = artifacts.require('./OrderFactory.sol');
const RegistryFactory = artifacts.require('./RegistryFactory.sol');
const RegistryStorage = artifacts.require('./RegistryStorage.sol');

async function deploy(deployer, network, accounts) {
    let
        dataProductFactory,
        feeStakesAddress,
        feeStakesFactory,
        feeStakesStorage,
        orderFactory,
        registryAddress,
        registryFactory,
        registryStorage
    ;

    await deployer.deploy(AddressArrayRemover);
    await deployer.link(AddressArrayRemover, [DataProductFactory, FeeStakesStorage, RegistryStorage]);

    let demoTokenAddress = '0xfa19d4e302336d61b895ea3b26bf4864bdd1d8ab';
    if (network !== 'rinkeby') {
        await deployer.deploy(DemoToken);
        demoTokenAddress = DemoToken.address;
    }

    dataProductFactory = await deployer.deploy(DataProductFactory);
    feeStakesStorage = await deployer.deploy(FeeStakesStorage);
    feeStakesFactory = await deployer.deploy(FeeStakesFactory, FeeStakesStorage.address);
    orderFactory = await deployer.deploy(OrderFactory);
    registryStorage = await deployer.deploy(RegistryStorage);
    registryFactory = await deployer.deploy(RegistryFactory, RegistryStorage.address);

    await feeStakesStorage.addPrivilegedAddress(FeeStakesFactory.address);
    await feeStakesStorage.initialized();

    await feeStakesFactory.createFeeStakes(FeeStakesStorage.address);

    await feeStakesStorage.removePrivilegedAddress(FeeStakesFactory.address);
    feeStakesAddress = await feeStakesStorage.getCurrentFeeStakesAddress();

    await registryStorage.addPrivilegedAddress(RegistryFactory.address);
    await registryStorage.initialized();

    await registryFactory.createRegistry(
        RegistryStorage.address,
        demoTokenAddress,
        DataProductFactory.address,
        feeStakesAddress,
        OrderFactory.address
    );

    await registryStorage.removePrivilegedAddress(RegistryFactory.address);
    registryAddress = await registryStorage.getCurrentRegistryAddress();

    await dataProductFactory.setRegistry(registryAddress);
    await orderFactory.setRegistry(registryAddress);
}

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
            await deploy(deployer, network, accounts);
        }
    );
};
