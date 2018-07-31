require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: process.env.TRUFFLE_NETWORK_HOST || '192.168.99.100',
            port: process.env.TRUFFLE_NETWORK_PORT || 8545,
            network_id: process.env.TRUFFLE_NETWORK_ID || '*'
        },
        dev: {
            host: process.env.TRUFFLE_NETWORK_HOST || '127.0.0.1',
            port: process.env.TRUFFLE_NETWORK_PORT || 7545,
            network_id: process.env.TRUFFLE_NETWORK_ID || '*'
        },
        env: {
            host: process.env.TRUFFLE_NETWORK_HOST || 'repux-ganache',
            port: process.env.TRUFFLE_NETWORK_PORT || 8545,
            network_id: process.env.TRUFFLE_NETWORK_ID || '*'
        },
        rinkeby: {
            host: "localhost",
            port: 8546,
            network_id: 4
        }
    }
};
