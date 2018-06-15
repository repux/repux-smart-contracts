const AddressArrayRemover = artifacts.require('./AddressArrayRemover.sol');
const DemoToken = artifacts.require('./DemoToken.sol');
const DataProductFactory = artifacts.require('./DataProductFactory.sol');
const Registry = artifacts.require('./Registry.sol');

async function deploy(deployer, network, accounts) {
    let dataProductFactory;

    await deployer.deploy(AddressArrayRemover);
    await deployer.link(AddressArrayRemover, [Registry, DataProductFactory]);

    await deployer.deploy(DemoToken);
    dataProductFactory = await deployer.deploy(DataProductFactory);

    await deployer.deploy(
        Registry,
        DemoToken.address,
        DataProductFactory.address
    );

    await dataProductFactory.setRegistry(Registry.address);
}

module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
            if (network === 'rinkeby') {
                await deployer.deploy(Registry, '0xfa19d4e302336d61b895ea3b26bf4864bdd1d8ab');
            } else {
                await deploy(deployer, network, accounts);
            }
        }
    );
};
