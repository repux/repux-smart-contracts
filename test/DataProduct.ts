const DataProduct = artifacts.require('./DataProduct.sol');
const Registry = <any>artifacts.require('./Registry.sol');

import { assert } from "chai";

contract('DataProduct', (accounts) => {
    it(`should change 'description' when 'setDescription' is called`, async () => {
        const registry = await Registry.deployed();

        const INITAL_DESCRIPTION = 'description';

        const dataProduct = await DataProduct.new(
            accounts[0],
            registry.address,
            'name',
            INITAL_DESCRIPTION,
            'hash',
            1
        );

        let description = await dataProduct.description();

        assert.equal(description, INITAL_DESCRIPTION);

        const NEW_DESCRIPTION = 'New description';

        await dataProduct.setDescription(NEW_DESCRIPTION);

        description = await dataProduct.description();        
        
        assert.equal(description, NEW_DESCRIPTION);              
    });
});
