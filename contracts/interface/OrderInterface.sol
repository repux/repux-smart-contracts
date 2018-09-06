pragma solidity ^0.4.24;


contract OrderInterface {
    function price() public view returns (uint256);
    function fee() public view returns (uint256);
    function cancelPurchase() external;
    function finalise(string _buyerMetaHash) external;
    function rate(uint8 score) external;
}
