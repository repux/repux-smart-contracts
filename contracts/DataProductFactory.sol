pragma solidity 0.4.24;

import "./DataProduct.sol";
import "./DataProductFactoryInterface.sol";
import "./Ownable.sol";


contract DataProductFactory is Ownable, DataProductFactoryInterface {
    address public registryAddress;

    modifier onlyRegistry() {
        require(msg.sender == registryAddress);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setRegistry(address _registryAddress) public onlyOwner {
        registryAddress = _registryAddress;
    }

    function createDataProduct(
        address _orderFactoryAddress,
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price,
        uint8 _daysToDeliver
    )
        public
        onlyRegistry
        returns
    (
        address
    ) {
        return new DataProduct(
            msg.sender,
            _orderFactoryAddress,
            _owner,
            _tokenAddress,
            _sellerMetaHash,
            _price,
            _daysToDeliver
        );
    }
}
