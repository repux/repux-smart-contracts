module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: "local.dev.api.repux",
            port: 8545,
            network_id: "*" // Match any network id
        }
    }
};
