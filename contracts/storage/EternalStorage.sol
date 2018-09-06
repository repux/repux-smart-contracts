pragma solidity ^0.4.24;

import "./EternalStorageInterface.sol";
import "../utils/AddressArrayRemover.sol";
import "../utils/Ownable.sol";


contract EternalStorage is Ownable, EternalStorageInterface {
    using AddressArrayRemover for address[];

    mapping(bytes32 => uint256) internal uIntStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

    mapping(bytes32 => uint256[]) internal uIntArrayStorage;
    mapping(bytes32 => address[]) internal addressArrayStorage;
    mapping(bytes32 => int256[]) internal intArrayStorage;

    modifier onlyAllowedContract() {
        if (boolStorage[keccak256(abi.encodePacked("contract.storage.initialised"))] == true) {
            require(addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] != address(0));
        }
        _;
    }

    constructor() public {
        owner = msg.sender;
        boolStorage[keccak256(abi.encodePacked("access.role", "owner", msg.sender))] = true;
    }

    function initialized() onlyOwner public {
        boolStorage[keccak256(abi.encodePacked("contract.storage.initialised"))] = true;
    }

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    function setAddress(bytes32 _key, address _value) onlyAllowedContract external {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) onlyAllowedContract external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) onlyAllowedContract external {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) onlyAllowedContract external {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) onlyAllowedContract external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) onlyAllowedContract external {
        intStorage[_key] = _value;
    }

    function deleteAddress(bytes32 _key) onlyAllowedContract external {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) onlyAllowedContract external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) onlyAllowedContract external {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) onlyAllowedContract external {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) onlyAllowedContract external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) onlyAllowedContract external {
        delete intStorage[_key];
    }

    function getAddressArray(bytes32 _key) external view returns (address[]) {
        return addressArrayStorage[_key];
    }

    function getUintArray(bytes32 _key) external view returns (uint[]) {
        return uIntArrayStorage[_key];
    }

    function getIntArray(bytes32 _key) external view returns (int[]) {
        return intArrayStorage[_key];
    }

    function addAddressToArray(bytes32 _key, address _value) onlyAllowedContract external {
        addressArrayStorage[_key].push(_value);
    }

    function addUintToArray(bytes32 _key, uint _value) onlyAllowedContract external {
        uIntArrayStorage[_key].push(_value);
    }

    function addIntToArray(bytes32 _key, int _value) onlyAllowedContract external {
        intArrayStorage[_key].push(_value);
    }

    function removeAddressFromArray(bytes32 _key, address _value) onlyAllowedContract external {
        addressArrayStorage[_key].removeByValue(_value);
    }
}
