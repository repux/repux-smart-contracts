require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: "local.dev.api.repux",
            port: 8545,
            network_id: "*"
        },
        dev: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*"
        }
    }
};
