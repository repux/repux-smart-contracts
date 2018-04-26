/// <reference path="../node_modules/@types/node/index.d.ts" />

const Migrations = artifacts.require('./Migrations.sol');

module.exports = (deployer) => {
    deployer.deploy(Migrations);
};
