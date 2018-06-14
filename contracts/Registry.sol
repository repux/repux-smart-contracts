pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./DataProductFactoryInterface.sol";
import "./Feeable.sol";


contract Registry is Feeable {
    using SafeMath for uint256;

    enum DataProductEventAction { CREATE, UPDATE, DELETE, PURCHASE, CANCEL_PURCHASE, FINALISE, RATE, CANCEL_RATING }

    address public tokenAddress;
    ERC20 private token;

    address public dataProductFactoryAddress;
    DataProductFactoryInterface private dataProductFactory;

    address[] public dataProducts;
    mapping(address => address[]) public dataCreated;
    mapping(address => address[]) public dataPurchased;
    mapping(address => address[]) public dataFinalised;
    mapping(address => bool) public isDataProduct;

    event DataProductUpdate(address dataProduct, DataProductEventAction action, address sender);

    modifier onlyDataProduct {
        require(isDataProduct[msg.sender]);
        _;
    }

    modifier onlyOwnerOrDataProduct {
        require(msg.sender == owner || isDataProduct[msg.sender]);
        _;
    }

    constructor(address _tokenAddress, address _dataProductFactoryAddress) public {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        token = ERC20(tokenAddress);
        dataProductFactoryAddress = _dataProductFactoryAddress;
        dataProductFactory = DataProductFactoryInterface(dataProductFactoryAddress);
    }

    function withdraw() public onlyOwner {
        uint256 balance = token.balanceOf(this);

        require(balance > 0);

        assert(token.transfer(owner, balance));
    }

    function deleteDataProduct(address _address) public onlyOwnerOrDataProduct returns (bool) {
        uint256 dataProductBalance = token.balanceOf(_address);

        require(dataProductBalance == 0);

        bool deleted = false;
        uint256 deletedIndex = 0;

        for (; deletedIndex < dataProducts.length; deletedIndex++) {
            if (_address == dataProducts[deletedIndex]) {
                deleted = true;
                break;
            }
        }

        if (deleted) {
            isDataProduct[_address] = false;
            dataProducts[deletedIndex] = dataProducts[dataProducts.length.sub(1)];
            dataProducts.length = dataProducts.length.sub(1);

            triggerDataProductUpdate(_address, DataProductEventAction.DELETE, msg.sender);
        }

        return deleted;
    }

    function createDataProduct(string _sellerMetaHash, uint256 _price) public returns (address) {
        address newDataProduct = dataProductFactory.createDataProduct(msg.sender, tokenAddress, _sellerMetaHash, _price);
        dataProducts.push(newDataProduct);
        dataCreated[msg.sender].push(newDataProduct);
        isDataProduct[newDataProduct] = true;

        triggerDataProductUpdate(newDataProduct, DataProductEventAction.CREATE, msg.sender);

        return newDataProduct;
    }

    function registerPurchase(address sender) public onlyDataProduct {
        dataPurchased[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.PURCHASE, sender);
    }

    function registerCancelPurchase(address sender) public onlyDataProduct {
        dataPurchased[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.CANCEL_PURCHASE, sender);
    }

    function registerFinalise(address sender) public onlyDataProduct {
        dataFinalised[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.FINALISE, sender);
    }

    function registerUpdate(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.UPDATE, sender);
    }

    function registerRating(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.RATE, sender);
    }

    function registerCancelRating(address sender) external onlyDataProduct {
        triggerDataProductUpdate(msg.sender, DataProductEventAction.CANCEL_RATING, sender);
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
