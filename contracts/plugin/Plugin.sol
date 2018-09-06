pragma solidity ^0.4.24;

import "../storage/EternalStorageInterface.sol";
import "../utils/Ownable.sol";
import "../utils/SafeMath.sol";
import "../utils/Versionable.sol";


contract Plugin is Ownable, Versionable {
    using SafeMath for uint256;

    address private pluginStorageAddress;
    EternalStorageInterface private pluginStorage;

    constructor(
        address _owner,
        address _storageAddress,
        uint16 _version
    )
    public
    {
        require(
            _owner != address(0) &&
            _storageAddress != address(0),
            "Incorrect initial addresses"
        );

        owner = _owner;
        version = _version;
        pluginStorageAddress = _storageAddress;
        pluginStorage = EternalStorageInterface(pluginStorageAddress);
    }
}
