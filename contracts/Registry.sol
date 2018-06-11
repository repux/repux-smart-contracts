pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./DataProductFactoryInterface.sol";
import "./Feeable.sol";


contract Registry is Feeable {
    using SafeMath for uint256;

    enum DataProductEventAction { CREATE, UPDATE, DELETE, PURCHASE, APPROVE, RATE, CANCEL_RATING }

    address public tokenAddress;
    ERC20 private token;

    address public dataProductFactoryAddress;
    DataProductFactoryInterface private dataProductFactory;

    address[] public dataProducts;
    mapping(address => address[]) public dataCreated;
    mapping(address => address[]) public dataPurchased;
    mapping(address => address[]) public dataApproved;
    mapping(address => bool) public isDataProduct;

    uint256 public feesDeposit;

    event DataProductUpdate(address dataProduct, DataProductEventAction action, address sender);
    event FeesDepositUpdate(address dataProduct, uint256 newFee);

    modifier onlyDataProduct {
        require(isDataProduct[msg.sender]);
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
        require(balance > feesDeposit);

        assert(token.transfer(owner, balance.sub(feesDeposit)));
    }

    function deleteDataProduct(address addr) public onlyOwner returns (bool) {
        bool deleted = false;
        uint256 deletedIndex = 0;

        for (; deletedIndex < dataProducts.length; deletedIndex++) {
            if (addr == dataProducts[deletedIndex]) {
                deleted = true;
                break;
            }
        }

        if (deleted) {
            isDataProduct[addr] = false;
            dataProducts[deletedIndex] = dataProducts[dataProducts.length.sub(1)];
            delete dataProducts[dataProducts.length.sub(1)];
            dataProducts.length = dataProducts.length.sub(1);
            isDataProduct[addr] = false;

            triggerDataProductUpdate(addr, DataProductEventAction.DELETE, msg.sender);
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

    function setFeesDeposit(uint256 fee) public onlyDataProduct {
        feesDeposit = fee;

        emit FeesDepositUpdate(msg.sender, fee);
    }

    function registerPurchase(address sender) public onlyDataProduct {
        dataPurchased[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.PURCHASE, sender);
    }

    function registerApprove(address sender) public onlyDataProduct {
        dataApproved[sender].push(msg.sender);

        triggerDataProductUpdate(msg.sender, DataProductEventAction.APPROVE, sender);
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

    function getDataCreatedFor(address addr) public view returns (address[]) {
        return dataCreated[addr];
    }

    function getDataCreated() public view returns (address[]) {
        return getDataCreatedFor(msg.sender);
    }

    function getDataPurchasedFor(address addr) public view returns (address[]) {
        return dataPurchased[addr];
    }

    function getDataPurchased() public view returns (address[]) {
        return getDataPurchasedFor(msg.sender);
    }

    function getDataApprovedFor(address addr) public view returns (address[]) {
        return dataApproved[addr];
    }

    function getDataApproved() public view returns (address[]) {
        return getDataApprovedFor(msg.sender);
    }

    function triggerDataProductUpdate(address dataProduct, DataProductEventAction action, address sender) internal {
        emit DataProductUpdate(dataProduct, action, sender);
    }
}
