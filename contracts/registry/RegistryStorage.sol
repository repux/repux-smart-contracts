pragma solidity ^0.4.24;

import "../interface/RegistryStorageInterface.sol";
import "../storage/EternalStorage.sol";


contract RegistryStorage is EternalStorage, RegistryStorageInterface {
    function addPrivilegedAddress(address _value) onlyOwner public {
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = _value;
    }

    function removePrivilegedAddress(address _value) onlyOwner public {
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = address(0);
    }

    function addCurrentRegistryAddress(address _value) onlyAllowedContract public {
        addressStorage[keccak256(abi.encodePacked("current.registry"))] = _value;
        addressStorage[keccak256(abi.encodePacked("contract.address", _value))] = _value;
        addressArrayStorage[keccak256(abi.encodePacked("registries"))].push(_value);
    }

    function getRegistryAddresses() external view returns (address[]) {
        return this.getAddressArray(keccak256(abi.encodePacked("registries")));
    }

    function getCurrentRegistryAddress() external view returns (address) {
        return this.getAddress(keccak256(abi.encodePacked("current.registry")));
    }
}
