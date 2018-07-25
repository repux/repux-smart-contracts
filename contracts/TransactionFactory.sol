pragma solidity 0.4.24;

import "./Ownable.sol";
import "./RegistryInterface.sol";
import "./Transaction.sol";
import "./TransactionFactoryInterface.sol";


contract TransactionFactory is Ownable, TransactionFactoryInterface {
    address private registryAddress;
    RegistryInterface private registry;

    modifier onlyDataProduct {
        require(registry.isDataProduct(msg.sender));
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setRegistry(address _registryAddress) public onlyOwner {
        registryAddress = _registryAddress;
        registry = RegistryInterface(registryAddress);
    }

    function createTransaction(
        address _owner,
        address _buyerAddress,
        string _buyerPublicKey,
        uint256 _rateDeadline,
        uint256 _deliveryDeadline,
        uint256 _price,
        uint256 _fee
    )
        public
        onlyDataProduct
        returns
    (
        address
    ) {
        return new Transaction(
            msg.sender,
            _owner,
            _buyerAddress,
            _buyerPublicKey,
            _rateDeadline,
            _deliveryDeadline,
            _price,
            _fee
        );
    }
}
