pragma solidity ^0.4.24;

import "./interface/DataProductFactoryInterface.sol";
import "./interface/RegistryInterface.sol";
import "./storage/EternalStorageInterface.sol";
import "./token/ERC20.sol";
import "./utils/Feeable.sol";
import "./utils/SafeMath.sol";
import "./utils/Versionable.sol";


contract Registry is RegistryInterface, Feeable, Versionable {
    using SafeMath for uint256;

    enum DataProductEventAction { CREATE, UPDATE, DELETE, PURCHASE, CANCEL_PURCHASE, FINALISE, RATE }

    address private registryStorageAddress;
    EternalStorageInterface private registryStorage;

    address private tokenAddress;
    ERC20 private token;

    address private dataProductFactoryAddress;
    DataProductFactoryInterface private dataProductFactory;

    address private orderFactoryAddress;

    string private dataProductsKey = "dataProducts";
    string private dataCreatedKey = "dataCreated";
    string private dataPurchasedKey = "dataPurchased";
    string private dataFinalisedKey = "dataFinalised";
    string private registeredDataProductsKey = "registeredDataProducts";
    string private identifiedCustomersKey = "identifiedCustomers";

    bool private updating = false;

    event DataProductUpdate(address dataProduct, DataProductEventAction action, address sender);

    modifier notUpdating {
        require(!updating);
        _;
    }

    modifier onlyDataProduct {
        require(isDataProduct(msg.sender));
        _;
    }

    modifier onlyOwnerOrDataProduct {
        require(msg.sender == owner || isDataProduct(msg.sender));
        _;
    }

    constructor(
        address _owner,
        address _storageAddress,
        address _tokenAddress,
        address _dataProductFactoryAddress,
        address _orderFactoryAddress,
        uint16 _version
    )
        public
    {
        require(
            _owner != address(0) &&
            _storageAddress != address(0) &&
            _tokenAddress != address(0) &&
            _dataProductFactoryAddress != address(0) &&
            _orderFactoryAddress != address(0),
            "Incorrect initial addresses"
        );

        owner = _owner;
        version = _version;
        registryStorageAddress = _storageAddress;
        registryStorage = EternalStorageInterface(registryStorageAddress);

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

    function deleteDataProduct(address _address) public onlyOwnerOrDataProduct notUpdating returns (bool) {
        uint256 dataProductBalance = token.balanceOf(_address);

        require(dataProductBalance == 0, "Can not delete Data Product which holds the funds");

        registryStorage.removeAddressFromArray(keccak256(abi.encodePacked(dataProductsKey)), _address);
        registryStorage.setBool(keccak256(abi.encodePacked(registeredDataProductsKey, _address)), false);

        triggerDataProductUpdate(_address, DataProductEventAction.DELETE, msg.sender);

        return true;
    }

    function createDataProduct(
        string _sellerMetaHash,
        uint256 _price,
        uint8 _daysToDeliver
    )
        public
        notUpdating
        returns
    (
        address
    )
    {
        address newDataProduct = dataProductFactory.createDataProduct(
            orderFactoryAddress,
            msg.sender,
            tokenAddress,
            _sellerMetaHash,
            _price,
            _daysToDeliver
        );
        registryStorage.addAddressToArray(keccak256(abi.encodePacked(dataProductsKey)), newDataProduct);
        registryStorage.addAddressToArray(keccak256(abi.encodePacked(dataCreatedKey, msg.sender)), newDataProduct);
        registryStorage.setBool(keccak256(abi.encodePacked(registeredDataProductsKey, newDataProduct)), true);

        triggerDataProductUpdate(newDataProduct, DataProductEventAction.CREATE, msg.sender);

        return newDataProduct;
    }

    function setUpdating(bool _value) public onlyOwner {
        updating = _value;
    }

    function isDataProduct(address _address) public view returns (bool) {
        return registryStorage.getBool(keccak256(abi.encodePacked(registeredDataProductsKey, _address)));
    }

    function isIdentifiedCustomer(address _address) public view returns (bool) {
        return registryStorage.getBool(keccak256(abi.encodePacked(identifiedCustomersKey, _address)));
    }

    function setIdentifiedCustomer(address _address, bool _isKyc) public onlyOwner {
        require(_address != address(0), "Address cannot be empty");
        bool currentValue = registryStorage.getBool(keccak256(abi.encodePacked(identifiedCustomersKey, _address)));

        require(currentValue != _isKyc, "This value is already set for that address");

        registryStorage.setBool(keccak256(abi.encodePacked(identifiedCustomersKey, _address)), _isKyc);
    }

    function setDataProductFactoryAddress(address _dataProductFactoryAddress) public onlyOwner {
        require(_dataProductFactoryAddress != address(0), "Address cannot be empty");
        require(dataProductFactoryAddress != _dataProductFactoryAddress, "This value is already set for that address");

        dataProductFactoryAddress = _dataProductFactoryAddress;
        dataProductFactory = DataProductFactoryInterface(dataProductFactoryAddress);
    }

    function setOrderFactoryAddress(address _orderFactoryAddress) public onlyOwner {
        require(_orderFactoryAddress != address(0), "Address cannot be empty");
        require(orderFactoryAddress != _orderFactoryAddress, "This value is already set for that address");

        orderFactoryAddress = _orderFactoryAddress;
    }

    function registerPurchase(address sender) external onlyDataProduct {
        registryStorage.addAddressToArray(keccak256(abi.encodePacked(dataPurchasedKey, sender)), msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.PURCHASE, sender);
    }

    function registerCancelPurchase(address sender) external onlyDataProduct {
        registryStorage.removeAddressFromArray(keccak256(abi.encodePacked(dataPurchasedKey, sender)), msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.CANCEL_PURCHASE, sender);
    }

    function registerFinalise(address sender) external onlyDataProduct {
        registryStorage.addAddressToArray(keccak256(abi.encodePacked(dataFinalisedKey, sender)), msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.FINALISE, sender);
    }

    function registerUpdate(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.UPDATE, sender);
    }

    function registerRating(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.RATE, sender);
    }

    function getDataProducts() public view returns (address[]){
        return registryStorage.getAddressArray(keccak256(abi.encodePacked(dataProductsKey)));
    }

    function getDataCreatedFor(address _address) public view returns (address[]) {
        return registryStorage.getAddressArray(keccak256(abi.encodePacked(dataCreatedKey, _address)));
    }

    function getDataCreated() public view returns (address[]) {
        return getDataCreatedFor(msg.sender);
    }

    function getDataPurchasedFor(address _address) public view returns (address[]) {
        return registryStorage.getAddressArray(keccak256(abi.encodePacked(dataPurchasedKey, _address)));
    }

    function getDataPurchased() public view returns (address[]) {
        return getDataPurchasedFor(msg.sender);
    }

    function getDataFinalisedFor(address _address) public view returns (address[]) {
        return registryStorage.getAddressArray(keccak256(abi.encodePacked(dataFinalisedKey, _address)));
    }

    function getDataFinalised() public view returns (address[]) {
        return getDataFinalisedFor(msg.sender);
    }

    function triggerDataProductUpdate(address dataProduct, DataProductEventAction action, address sender) internal {
        emit DataProductUpdate(dataProduct, action, sender);
    }
}
