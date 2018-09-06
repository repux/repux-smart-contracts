pragma solidity ^0.4.24;


contract FeeableInterface {
    function getOrderFee(uint256 price) public view returns (uint256);
}
