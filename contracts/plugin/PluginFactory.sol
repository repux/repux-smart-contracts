pragma solidity ^0.4.24;

import "./Plugin.sol";
import "../interface/PluginStorageInterface.sol";
import "../utils/Ownable.sol";
import "../utils/Versionable.sol";


contract PluginFactory is Ownable, Versionable {
    address private pluginStorageAddress;
    PluginStorageInterface private pluginStorage;
    bool public created;

    constructor(address _storageAddress) public {
        require(_storageAddress != address(0), "Incorrect storage address");

        owner = msg.sender;
        version = 1;
        created = false;

        pluginStorageAddress = _storageAddress;
        pluginStorage = PluginStorageInterface(pluginStorageAddress);
    }

    function createPlugin(address _storageAddress) public onlyOwner returns (address) {
        require(!created, "Cannot create more than one Plugin contract");

        address newPluginAddress = new Plugin(
            msg.sender,
            _storageAddress,
            version
        );

        pluginStorage.addCurrentPluginAddress(newPluginAddress);
        created = true;

        return newPluginAddress;
    }
}
