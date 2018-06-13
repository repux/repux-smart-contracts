pragma solidity 0.4.24;


contract DataProductFactoryInterface {
    function createDataProduct(
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price
    ) public returns (
        address
    );
}