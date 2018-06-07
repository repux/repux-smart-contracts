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
    deployer.then(() => {
        if (network === 'rinkeby') {
            deployer.deploy(Registry, '0xfa19d4e302336d61b895ea3b26bf4864bdd1d8ab');
        }
        else {
            deploy(deployer, network, accounts)
        }
    }
    );
};
