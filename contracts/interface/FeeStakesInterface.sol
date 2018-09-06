pragma solidity ^0.4.24;


contract FeeStakesInterface {
    function getOrderFee(uint256 price) public view returns (uint256);
}
