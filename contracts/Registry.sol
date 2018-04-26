pragma solidity 0.4.23;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./DataProduct.sol";
import "./Feeable.sol";


contract Registry is Feeable {
    using SafeMath for uint256;

    address public tokenAddress;
    ERC20 private token;

    address[] public dataProducts;
    mapping(address => address[]) public dataCreated;
    mapping(address => address[]) public dataPurchased;
    mapping(address => bool) public isDataProduct;

    uint256 public feesDeposit;

    event CreateDataProduct(address dataProduct, string sellerMetaHash);
    event PurchaseDataProduct(address dataProduct, address buyer);
    event RateDataProduct(address dataProduct, address rater, uint8 score);
    event CancelRating(address dataProduct, address rater);
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
        }

        return deleted;
    }

    function createDataProduct(string sellerMetaHash, uint256 _price) public returns (address) {
        address newDataProduct = new DataProduct(msg.sender, tokenAddress, sellerMetaHash, _price);
        dataProducts.push(newDataProduct);
        dataCreated[msg.sender].push(newDataProduct);
        isDataProduct[newDataProduct] = true;
        emit CreateDataProduct(newDataProduct, sellerMetaHash);

        return newDataProduct;
    }

    function setFeesDeposit(uint256 fee) public onlyDataProduct {
        feesDeposit = fee;
        emit FeesDepositUpdate(msg.sender, fee);
    }

    function registerUserPurchase(address user) public onlyDataProduct {
        dataPurchased[user].push(msg.sender);
        emit PurchaseDataProduct(msg.sender, user);
    }

    function registerRating(address user, uint8 score) public onlyDataProduct {
        emit RateDataProduct(msg.sender, user, score);
    }

    function registerCancelRating(address user) public onlyDataProduct {
        emit CancelRating(msg.sender, user);
    }

    function getDataProducts() public constant returns (address[]){
        return dataProducts;
    }

    function getDataCreatedFor(address addr) public constant returns (address[]) {
        return dataCreated[addr];
    }

    function getDataCreated() public constant returns (address[]) {
        return getDataCreatedFor(msg.sender);
    }

    function getDataPurchasedFor(address addr) public constant returns (address[]) {
        return dataPurchased[addr];
    }

    function getDataPurchased() public constant returns (address[]) {
        return getDataPurchasedFor(msg.sender);
    }
}
