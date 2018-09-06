pragma solidity ^0.4.24;


contract PluginStorageInterface {
    function addPrivilegedAddress(address _value) public;
    function removePrivilegedAddress(address _value) public;
    function addCurrentPluginAddress(address _value) public;
    function getPluginAddresses() external view returns (address[]);
    function getCurrentPluginAddress() external view returns (address);
}
