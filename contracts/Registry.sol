pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./DataProduct.sol";
import "./Feeable.sol";


contract Registry is Feeable {
    using SafeMath for uint256;

    enum DataProductUpdateAction { CREATE, UPDATE, DELETE, PURCHASE, APPROVE, RATE, CANCEL_RATING }

    address public tokenAddress;
    ERC20 private token;

    address[] public dataProducts;
    mapping(address => address[]) public dataCreated;
    mapping(address => address[]) public dataPurchased;
    mapping(address => address[]) public dataApproved;
    mapping(address => bool) public isDataProduct;

    uint256 public feesDeposit;

    event DataProductUpdate(address dataProduct, DataProductUpdateAction action, address userAddress);
    event FeesDepositUpdate(address dataProduct, uint256 newFee);

    modifier onlyDataProduct {
        require(isDataProduct[msg.sender]);
        _;
    }

    constructor(address _tokenAddress) public {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        token = ERC20(tokenAddress);
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

            emitDataProductUpdate(addr, DataProductUpdateAction.DELETE, msg.sender);
        }

        return deleted;
    }

    function createDataProduct(string sellerMetaHash, uint256 _price) public returns (address) {
        address newDataProduct = new DataProduct(msg.sender, tokenAddress, sellerMetaHash, _price);
        dataProducts.push(newDataProduct);
        dataCreated[msg.sender].push(newDataProduct);
        isDataProduct[newDataProduct] = true;

        emitDataProductUpdate(newDataProduct, DataProductUpdateAction.CREATE, msg.sender);

        return newDataProduct;
    }

    function setFeesDeposit(uint256 fee) public onlyDataProduct {
        feesDeposit = fee;

        emit FeesDepositUpdate(msg.sender, fee);
    }

    function registerPurchase(address user) public onlyDataProduct {
        dataPurchased[user].push(msg.sender);

        emitDataProductUpdate(msg.sender, DataProductUpdateAction.PURCHASE, user);
    }

    function registerApprove(address user) public onlyDataProduct {
        dataApproved[user].push(msg.sender);

        emitDataProductUpdate(msg.sender, DataProductUpdateAction.APPROVE, user);
    }

    function registerUpdate(address user) external onlyDataProduct {
        emitDataProductUpdate(msg.sender, DataProductUpdateAction.UPDATE, user);
    }

    function registerRating(address user) external onlyDataProduct {
        emitDataProductUpdate(msg.sender, DataProductUpdateAction.RATE, user);
    }

    function registerCancelRating(address user) external onlyDataProduct {
        emitDataProductUpdate(msg.sender, DataProductUpdateAction.CANCEL_RATING, user);
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

    function emitDataProductUpdate(address dataProduct, DataProductUpdateAction action, address userAddress) public {
        emit DataProductUpdate(dataProduct, action, userAddress);
    }
}
