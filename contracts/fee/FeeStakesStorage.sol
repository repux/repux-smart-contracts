pragma solidity ^0.4.24;

import "../interface/FeeStakesStorageInterface.sol";
import "../storage/EternalStorage.sol";


contract FeeStakesStorage is EternalStorage, FeeStakesStorageInterface {
    function addPrivilegedAddress(address _value) onlyOwner public {
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = _value;
    }

    function removePrivilegedAddress(address _value) onlyOwner public {
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = address(0);
    }

    function addCurrentFeeStakesAddress(address _value) onlyAllowedContract public {
        addressStorage[keccak256(abi.encodePacked("current.fee"))] = _value;
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = _value;
        addressArrayStorage[keccak256(abi.encodePacked("fees"))].push(_value);
    }

    function getFeeStakesAddresses() external view returns (address[]) {
        return this.getAddressArray(keccak256(abi.encodePacked("fees")));
    }

    function getCurrentFeeStakesAddress() external view returns (address) {
        return this.getAddress(keccak256(abi.encodePacked("current.fee")));
    }
}
