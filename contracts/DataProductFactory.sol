pragma solidity 0.4.24;

import "./DataProduct.sol";
import "./Ownable.sol";


contract DataProductFactory is Ownable, DataProductFactoryInterface {
    constructor() public {
        owner = msg.sender;
    }

    function createDataProduct(
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price
    ) public returns (
        address
    ) {
        return new DataProduct(msg.sender, _owner, _tokenAddress, _sellerMetaHash, _price);
    }
}
