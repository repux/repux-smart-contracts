pragma solidity 0.4.24;

import "./AddressArrayRemover.sol";
import "./DataProductFactoryInterface.sol";
import "./ERC20.sol";
import "./Feeable.sol";
import "./RegistryInterface.sol";
import "./SafeMath.sol";


contract Registry is RegistryInterface, Feeable {
    using AddressArrayRemover for address[];
    using SafeMath for uint256;

    enum DataProductEventAction { CREATE, UPDATE, DELETE, PURCHASE, CANCEL_PURCHASE, FINALISE, RATE }

    address private tokenAddress;
    ERC20 private token;

    address private dataProductFactoryAddress;
    DataProductFactoryInterface private dataProductFactory;

    address private orderFactoryAddress;

    address[] private dataProducts;
    mapping(address => address[]) private dataCreated;
    mapping(address => address[]) private dataPurchased;
    mapping(address => address[]) private dataFinalised;
    mapping(address => bool) private registeredDataProducts;
    mapping(address => bool) private identifiedCustomers;

    event DataProductUpdate(address dataProduct, DataProductEventAction action, address sender);

    modifier onlyDataProduct {
        require(isDataProduct(msg.sender));
        _;
    }

    modifier onlyOwnerOrDataProduct {
        require(msg.sender == owner || isDataProduct(msg.sender));
        _;
    }

    constructor(address _tokenAddress, address _dataProductFactoryAddress, address _orderFactoryAddress) public {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        token = ERC20(tokenAddress);
        dataProductFactoryAddress = _dataProductFactoryAddress;
        dataProductFactory = DataProductFactoryInterface(dataProductFactoryAddress);
        orderFactoryAddress = _orderFactoryAddress;
    }

    function withdraw() public onlyOwner {
        uint256 balance = token.balanceOf(this);

        require(balance > 0);

        assert(token.transfer(owner, balance));
    }

    function deleteDataProduct(address _address) public onlyOwnerOrDataProduct returns (bool) {
        uint256 dataProductBalance = token.balanceOf(_address);

        require(dataProductBalance == 0, "Can not delete Data Product which holds the funds");

        dataProducts.removeByValue(_address);
        registeredDataProducts[_address] = false;

        triggerDataProductUpdate(_address, DataProductEventAction.DELETE, msg.sender);

        return true;
    }

    function createDataProduct(string _sellerMetaHash, uint256 _price, uint8 _daysToDeliver) public returns (address) {
        address newDataProduct = dataProductFactory.createDataProduct(
            orderFactoryAddress,
            msg.sender,
            tokenAddress,
            _sellerMetaHash,
            _price,
            _daysToDeliver
        );
        dataProducts.push(newDataProduct);
        dataCreated[msg.sender].push(newDataProduct);
        registeredDataProducts[newDataProduct] = true;

        triggerDataProductUpdate(newDataProduct, DataProductEventAction.CREATE, msg.sender);

        return newDataProduct;
    }

    function isDataProduct(address _address) public view returns (bool) {
        return registeredDataProducts[_address];
    }

    function isIdentifiedCustomer(address _address) public view returns (bool) {
        return identifiedCustomers[_address];
    }

    function setIdentifiedCustomer(address _address, bool _isKyc) public onlyOwner {
        require(_address != address(0), "Address cannot be empty");
        require(identifiedCustomers[_address] != _isKyc, "This value is already set for that address");

        identifiedCustomers[_address] = _isKyc;
    }

    function registerPurchase(address sender) external onlyDataProduct {
        dataPurchased[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.PURCHASE, sender);
    }

    function registerCancelPurchase(address sender) external onlyDataProduct {
        dataPurchased[sender].removeByValue(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.CANCEL_PURCHASE, sender);
    }

    function registerFinalise(address sender) external onlyDataProduct {
        dataFinalised[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.FINALISE, sender);
    }

    function registerUpdate(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.UPDATE, sender);
    }

    function registerRating(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.RATE, sender);
    }

    function getDataProducts() public view returns (address[]){
        return dataProducts;
    }

    function getDataCreatedFor(address _address) public view returns (address[]) {
        return dataCreated[_address];
    }

    function getDataCreated() public view returns (address[]) {
        return getDataCreatedFor(msg.sender);
    }

    function getDataPurchasedFor(address _address) public view returns (address[]) {
        return dataPurchased[_address];
    }

    function getDataPurchased() public view returns (address[]) {
        return getDataPurchasedFor(msg.sender);
    }

    function getDataFinalisedFor(address _address) public view returns (address[]) {
        return dataFinalised[_address];
    }

    function getDataFinalised() public view returns (address[]) {
        return getDataFinalisedFor(msg.sender);
    }

    function triggerDataProductUpdate(address dataProduct, DataProductEventAction action, address sender) internal {
        emit DataProductUpdate(dataProduct, action, sender);
    }
}
