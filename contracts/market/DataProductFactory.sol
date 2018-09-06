pragma solidity ^0.4.24;

import "./DataProduct.sol";
import "../interface/DataProductFactoryInterface.sol";
import "../utils/Ownable.sol";
import "../utils/Versionable.sol";


contract DataProductFactory is Ownable, Versionable, DataProductFactoryInterface {
    address public registryAddress;

    modifier onlyRegistry() {
        require(msg.sender == registryAddress);
        _;
    }

    constructor() public {
        owner = msg.sender;
        version = 1;
    }

    function setRegistry(address _registryAddress) public onlyOwner {
        registryAddress = _registryAddress;
    }

    function createDataProduct(
        address _feeStakesAddress,
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
            _feeStakesAddress,
            _orderFactoryAddress,
            _owner,
            _tokenAddress,
            _sellerMetaHash,
            _price,
            _daysToDeliver,
            version
        );
    }
}
