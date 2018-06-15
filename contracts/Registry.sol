pragma solidity 0.4.24;

import "./AddressArrayRemover.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./DataProductFactoryInterface.sol";
import "./Feeable.sol";


contract Registry is Feeable {
    using AddressArrayRemover for address[];
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

        require(dataProductBalance == 0, "Can not delete Data Product which holds the funds");

        dataProducts.removeByValue(_address);
        isDataProduct[_address] = false;

        triggerDataProductUpdate(_address, DataProductEventAction.DELETE, msg.sender);

        return true;
    }

    function createDataProduct(string _sellerMetaHash, uint256 _price, uint8 _daysForDeliver) public returns (address) {
        address newDataProduct = dataProductFactory.createDataProduct(
            msg.sender,
            tokenAddress,
            _sellerMetaHash,
            _price,
            _daysForDeliver
        );
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
        dataPurchased[sender].removeByValue(msg.sender);

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
