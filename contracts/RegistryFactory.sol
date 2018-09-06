pragma solidity ^0.4.24;

import "./Registry.sol";
import "./interface/RegistryStorageInterface.sol";
import "./utils/Ownable.sol";
import "./utils/Versionable.sol";


contract RegistryFactory is Ownable, Versionable {
    address private registryStorageAddress;
    RegistryStorageInterface private registryStorage;
    bool public created;

    constructor(address _storageAddress) public {
        require(_storageAddress != address(0), "Incorrect storage address");

        owner = msg.sender;
        version = 1;
        created = false;

        registryStorageAddress = _storageAddress;
        registryStorage = RegistryStorageInterface(registryStorageAddress);
    }

    function createRegistry(
        address _storageAddress,
        address _tokenAddress,
        address _dataProductFactoryAddress,
        address _orderFactoryAddress
    )
        public
        onlyOwner
        returns
    (
        address
    ) {
        require(!created, "Cannot create more than one Registry contract");

        address newRegistryAddress = new Registry(
            msg.sender,
            _storageAddress,
            _tokenAddress,
            _dataProductFactoryAddress,
            _orderFactoryAddress,
            version
        );

        registryStorage.addCurrentRegistryAddress(newRegistryAddress);
        created = true;

        return newRegistryAddress;
    }
}
