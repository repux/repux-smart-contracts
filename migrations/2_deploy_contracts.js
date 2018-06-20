const DemoToken = artifacts.require('./DemoToken.sol');
const DataProductFactory = artifacts.require('./DataProductFactory.sol');
const Registry = artifacts.require('./Registry.sol');

async function deploy(deployer, network, accounts) {
    await deployer.deploy(DemoToken);
    await deployer.deploy(DataProductFactory);

    await deployer.deploy(
        Registry,
        DemoToken.address,
        DataProductFactory.address
    );
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
