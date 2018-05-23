require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: "192.168.99.100",
            port: 8545,
            network_id: "*"
        },
        dev: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*"
        },
        env: {
            host: process.env.TRUFFLE_NETWORK_HOST || 'repux-ganache',
            port: process.env.TRUFFLE_NETWORK_POST || 8545,
            network_id: process.env.TRUFFLE_NETWORK_ID || '*'
        }
    }
};
