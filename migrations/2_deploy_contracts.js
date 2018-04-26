const DemoToken = artifacts.require('./DemoToken.sol');
const Registry = artifacts.require('./Registry.sol');

async function deploy(deployer, network, accounts) {
    await deployer.deploy(DemoToken);

    await deployer.deploy(
        Registry,
        DemoToken.address
    );
}

module.exports = function (deployer, network, accounts) {
    deployer.then(() => deploy(deployer, network, accounts));
};
