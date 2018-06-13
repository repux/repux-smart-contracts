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

module.exports = function (deployer, network, accounts) {
    deployer.then(() => deploy(deployer, network, accounts));
};
