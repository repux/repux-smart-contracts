pragma solidity ^0.4.24;


contract DataProductInterface {
    function disable() public;
    function disabled() public view returns (bool);
    function purchaseFor(address _buyerAddress, string _buyerPublicKey) public returns (address);
    function purchase(string _buyerPublicKey) public returns (address);
    function cancelPurchase() public;
    function finalise(address buyerAddress, string buyerMetaHash) public;
    function rate(uint8 score) public;
}
