pragma solidity 0.4.24;

import "./AddressArrayRemover.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Registry.sol";


contract DataProduct is Ownable {
    using AddressArrayRemover for address[];
    using SafeMath for uint256;

    struct Transaction {
        address wallet;
        string publicKey;
        string buyerMetaHash;
        uint256 deliveryDeadline;
        uint256 price;
        uint256 fee;
        bool purchased;
        bool finalised;
        bool rated;
        uint8 rating;
    }

    mapping(address => Transaction) transactions;
    address[] private buyersAddresses;

    address public registryAddress;
    Registry public registry;

    address public tokenAddress;
    ERC20 private token;

    string public sellerMetaHash;
    uint256 public price;
    uint256 public creationTimeStamp;
    uint8 public daysForDeliver;
    uint8 public minScore = 0;
    uint8 public maxScore = 5;
    mapping(uint8 => uint256) public scoreCount;
    uint256 public rateCount;

    uint256 public buyersDeposit;

    bool public disabled = false;

    modifier onlyRegistry() {
        require(msg.sender == registryAddress);
        _;
    }

    modifier onlyBuyer() {
        require(transactions[msg.sender].wallet != address(0));
        _;
    }

    modifier onlyFinalised() {
        require(transactions[msg.sender].finalised);
        _;
    }

    modifier onlyEnabled() {
        require(!disabled);
        _;
    }

    constructor(
        address _registryAddress,
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price,
        uint8 _daysForDeliver
    )
        public
    {
        registryAddress = _registryAddress;
        registry = Registry(registryAddress);

        require(_price > registry.getTransactionFee(_price), "Price should be greater than transaction fee value");

        owner = _owner;
        tokenAddress = _tokenAddress;
        token = ERC20(tokenAddress);
        sellerMetaHash = _sellerMetaHash;
        price = _price;
        daysForDeliver = _daysForDeliver;
        creationTimeStamp = now;
    }

    function disable() public onlyOwner onlyEnabled {
        disabled = true;

        registry.registerUpdate(msg.sender);
    }

    function kill() public onlyOwner {
        require(disabled);

        registry.deleteDataProduct(this);
    }

    function withdraw() public onlyOwner {
        uint256 balance = token.balanceOf(this);

        require(balance > 0 && balance > buyersDeposit);

        assert(token.transfer(owner, balance.sub(buyersDeposit)));

        registry.registerUpdate(msg.sender);
    }

    function setPrice(uint256 newPrice) public onlyOwner onlyEnabled {
        require(newPrice > registry.getTransactionFee(newPrice), "Price should be greater than transaction fee value");

        price = newPrice;

        registry.registerUpdate(msg.sender);
    }

    function purchaseFor(address buyerAddress, string buyerPublicKey) public onlyEnabled {
        require(owner != buyerAddress);
        require(bytes(buyerPublicKey).length != 0);

        Transaction storage transaction = transactions[buyerAddress];

        require(!transaction.purchased);

        transaction.purchased = true;

        uint256 fee = registry.getTransactionFee(price);

        transaction.price = price;
        transaction.fee = fee;
        transaction.wallet = buyerAddress;
        transaction.publicKey = buyerPublicKey;
        transaction.deliveryDeadline = now + daysForDeliver * 1 days;

        buyersAddresses.push(buyerAddress);

        assert(token.transferFrom(msg.sender, this, price));

        buyersDeposit = buyersDeposit.add(price);

        registry.registerPurchase(buyerAddress);
    }

    function purchase(string publicKey) public onlyEnabled {
        purchaseFor(msg.sender, publicKey);
    }

    function cancelPurchase() public onlyBuyer {
        Transaction storage transaction = transactions[msg.sender];

        require(transaction.purchased && !transaction.finalised && now >= transaction.deliveryDeadline);

        uint256 transactionPrice = transaction.price;

        deleteTransaction();
        assert(token.transfer(msg.sender, transactionPrice));

        buyersDeposit = buyersDeposit.sub(transactionPrice);

        registry.registerCancelPurchase(msg.sender);
    }

    function deleteTransaction() private {
        buyersAddresses.removeByValue(msg.sender);

        delete transactions[msg.sender];
    }

    function finalise(address buyerAddress, string buyerMetaHash) public onlyOwner onlyEnabled {
        Transaction storage transaction = transactions[buyerAddress];

        require(transaction.purchased && !transaction.finalised);
        require(keccak256(abi.encodePacked(buyerMetaHash)) != keccak256(abi.encodePacked("")));

        transaction.finalised = true;
        transaction.buyerMetaHash = buyerMetaHash;

        if (transaction.fee > 0) {
            assert(token.transfer(registryAddress, transaction.fee));
        }

        buyersDeposit = buyersDeposit.sub(transaction.price);

        registry.registerFinalise(buyerAddress);
    }

    function rate(uint8 score) public onlyFinalised onlyEnabled {
        require(score >= minScore && score <= maxScore);

        Transaction storage transaction = transactions[msg.sender];

        if (transaction.rated) {
            uint8 originalScore = transaction.rating;
            require(score != originalScore);
            scoreCount[originalScore] = scoreCount[originalScore].sub(1);
        } else {
            rateCount = rateCount.add(1);
            transaction.rated = true;
        }

        scoreCount[score] = scoreCount[score].add(1);
        transaction.rating = score;

        registry.registerRating(msg.sender);
    }

    function cancelRating() public onlyFinalised onlyEnabled {
        Transaction storage transaction = transactions[msg.sender];

        require(transaction.rated);

        transaction.rated = false;
        uint8 score = transaction.rating;
        scoreCount[score] = scoreCount[score].sub(1);
        transaction.rating = 0;
        rateCount = rateCount.sub(1);

        registry.registerCancelRating(msg.sender);
    }

    function setSellerMetaHash(string _sellerMetaHash) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_sellerMetaHash)) != keccak256(abi.encodePacked("")));

        sellerMetaHash = _sellerMetaHash;

        registry.registerUpdate(msg.sender);
    }

    function setDaysForDeliver(uint8 _daysForDeliver) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_daysForDeliver)) != keccak256(abi.encodePacked("")));

        daysForDeliver = _daysForDeliver;

        registry.registerUpdate(msg.sender);
    }

    function getTotalRating() public constant returns (uint256) {
        uint256 total = 0;

        for (uint8 score = minScore; score <= maxScore; score++) {
            total = total.add(scoreCount[score].mul(score));
        }

        return total;
    }

    function getBuyersAddresses() public view returns (address[]) {
        return buyersAddresses;
    }

    function getTransactionData(address buyerAddress) public view returns (
        string _publicKey,
        string _buyerMetaHash,
        uint256 _deliveryDeadline,
        uint256 _price,
        uint256 _fee,
        bool _purchased,
        bool _finalised,
        bool _rated,
        uint8 _rating
    ) {
        Transaction storage transaction = transactions[buyerAddress];

        _publicKey = transaction.publicKey;
        _buyerMetaHash = transaction.buyerMetaHash;
        _deliveryDeadline = transaction.deliveryDeadline;
        _price = transaction.price;
        _fee = transaction.fee;
        _purchased = transaction.purchased;
        _finalised = transaction.finalised;
        _rated = transaction.rated;
        _rating = transaction.rating;
    }
}
