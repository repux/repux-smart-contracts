pragma solidity ^0.4.24;


contract RegistryStorageInterface {
    function addPrivilegedAddress(address _value) public;
    function removePrivilegedAddress(address _value) public;
    function addCurrentRegistryAddress(address _value) public;
    function getRegistryAddresses() external view returns (address[]);
    function getCurrentRegistryAddress() external view returns (address);
}
