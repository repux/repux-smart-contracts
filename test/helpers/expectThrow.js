const assert = require('chai').assert;

module.exports = async promise => {
    try {
        await promise;
    } catch (error) {
        console.log('Exception thrown: ' + error.message);
        const invalidOpcode = error.message.search('invalid opcode') >= 0;
        const outOfGas = error.message.search('out of gas') >= 0;
        const revert = error.message.search('revert') >= 0;
        assert(
            invalidOpcode || outOfGas || revert,
            'Expected throw, got \'' + error + '\' instead',
        );
        return;
    }
    assert.fail('Expected throw not received');
};
