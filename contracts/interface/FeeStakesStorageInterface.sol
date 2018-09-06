pragma solidity ^0.4.24;


contract FeeStakesStorageInterface {
    function addPrivilegedAddress(address _value) public;
    function removePrivilegedAddress(address _value) public;
    function addCurrentFeeStakesAddress(address _value) public;
    function getFeeStakesAddresses() external view returns (address[]);
    function getCurrentFeeStakesAddress() external view returns (address);
}
