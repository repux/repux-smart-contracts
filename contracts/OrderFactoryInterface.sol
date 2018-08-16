pragma solidity 0.4.24;


contract OrderFactoryInterface {
    function createOrder(
        address _owner,
        address _buyerAddress,
        string _buyerPublicKey,
        uint256 _rateDeadline,
        uint256 _deliveryDeadline,
        uint256 _price,
        uint256 _fee
    ) public returns (
        address
    );
}
