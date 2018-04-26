const DemoToken = artifacts.require('./DemoToken.sol');
const Registry = artifacts.require('./Registry.sol');

async function deploy(deployer) {
    await deployer.deploy(DemoToken);

    await deployer.deploy(
        Registry,
        DemoToken.address
    );
}

module.exports = function (deployer) {
    deployer.then(() => deploy(deployer));
};
