pragma solidity ^0.4.24;

import "./FeeStakes.sol";
import "../interface/FeeStakesStorageInterface.sol";
import "../utils/Ownable.sol";
import "../utils/Versionable.sol";


contract FeeStakesFactory is Ownable, Versionable {
    address private feeStorageAddress;
    FeeStakesStorageInterface private feeStorage;
    bool public created;

    constructor(address _storageAddress) public {
        require(_storageAddress != address(0), "Incorrect storage address");

        owner = msg.sender;
        version = 1;
        created = false;

        feeStorageAddress = _storageAddress;
        feeStorage = FeeStakesStorageInterface(feeStorageAddress);
    }

    function createFeeStakes(address _storageAddress) public onlyOwner returns (address) {
        require(!created, "Cannot create more than one FeeStakes contract");

        address newFeeStakesAddress = new FeeStakes(
            msg.sender,
            _storageAddress,
            version
        );

        feeStorage.addCurrentFeeStakesAddress(newFeeStakesAddress);
        created = true;

        return newFeeStakesAddress;
    }
}
