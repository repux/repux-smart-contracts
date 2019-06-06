const AliasList = artifacts.require('./AliasList.sol');

const should = require('chai').should();
const expectThrow = require('./helpers/expectThrow');

contract('AliasList', (accounts) => {
    let aliasList;

    const nick = 'nick';
    const desc = 'description';
    const newNick = 'new nick';
    const newDesc = 'new description';

    before(async () => {
        aliasList = await AliasList.deployed();
    });

    it('should be able to set and get alias', async () => {
        await aliasList.setAlias(nick, desc);
        const alias = await aliasList.getAlias.call();

        alias[0].should.equal(nick);
        alias[1].should.equal(desc);
    });

    it('should be able to update alias', async () => {
        await aliasList.setAlias(newNick, newDesc);
        const alias = await aliasList.getAlias.call();

        alias[0].should.equal(newNick);
        alias[1].should.equal(newDesc);
    });

    it('should be able to set and get alias with empty description', async () => {
        await aliasList.setAlias('empty_description', '', { from: accounts[2] });
        const alias = await aliasList.getAlias.call({ from: accounts[2] });

        alias[0].should.equal('empty_description');
        alias[1].should.equal('');
    });

    it('should be able to get alias of given address', async () => {
        const alias = await aliasList.getAliasFor.call(accounts[0], { from: accounts[2] });

        alias[0].should.equal(newNick);
        alias[1].should.equal(newDesc);
    });

    it('should not be able to set already existing alias', async () => {
        expectThrow(aliasList.setAlias(newNick, desc, { from: accounts[1] }));
        const alias = await aliasList.getAlias.call({ from: accounts[1] });

        alias[0].should.equal('');
        alias[1].should.equal('');
    });

    it('should not be able to set empty alias', async () => {
        expectThrow(aliasList.setAlias('', desc, { from: accounts[1] }));
        const alias = await aliasList.getAlias.call({ from: accounts[1] });

        alias[0].should.equal('');
        alias[1].should.equal('');
    });
});
