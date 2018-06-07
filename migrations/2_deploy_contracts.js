const DemoToken = artifacts.require('./DemoToken.sol');
const Registry = artifacts.require('./Registry.sol');

async function deploy(deployer, network, accounts) {
    await deployer.deploy(DemoToken);

    await deployer.deploy(
        Registry,
        DemoToken.address
    );
}

async function deploy_rinkeby(deployer, network, accounts) {
    await deployer.deploy(
        Registry,
        '0xfa19d4e302336d61b895ea3b26bf4864bdd1d8ab'
    );
}

module.exports = function (deployer, network, accounts) {
    deployer.then(() => {
        if (network === 'rinkeby') {
            deploy_rinkeby(deployer, network, accounts)
        }
        else {
            deploy(deployer, network, accounts)
        }
    }
    );
};
