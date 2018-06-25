pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Registry.sol";


contract DataProduct is Ownable {
    using SafeMath for uint256;

    struct Transaction {
        address wallet;
        string publicKey;
        string buyerMetaHash;
        uint256 price;
        uint256 fee;
        bool purchased;
        bool approved;
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

    modifier onlyApproved() {
        require(transactions[msg.sender].approved);
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
        uint256 _price
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
        creationTimeStamp = block.timestamp;
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

        require(balance > 0);
        require(balance > buyersDeposit);

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

        require(!transactions[buyerAddress].purchased);

        transaction.purchased = true;

        uint256 fee = registry.getTransactionFee(price);
        uint256 priceWithoutFee = price.sub(fee);

        assert(token.transferFrom(msg.sender, this, priceWithoutFee));
        if (fee > 0) {
            assert(token.transferFrom(msg.sender, registryAddress, fee));
        }

        transaction.price = price;
        transaction.fee = fee;
        transaction.wallet = buyerAddress;
        transaction.publicKey = buyerPublicKey;

        buyersAddresses.push(buyerAddress);

        buyersDeposit = buyersDeposit.add(priceWithoutFee);
        if (fee > 0) {
            uint256 feesDeposit = registry.feesDeposit();
            registry.setFeesDeposit(feesDeposit.add(fee));
        }

        registry.registerPurchase(buyerAddress);
    }

    function purchase(string publicKey) public onlyEnabled {
        purchaseFor(msg.sender, publicKey);
    }

    function approve(address buyerAddress, string buyerMetaHash) public onlyOwner onlyEnabled {
        Transaction storage transaction = transactions[buyerAddress];

        require(transaction.purchased);
        require(!transaction.approved);
        require(keccak256(abi.encodePacked(buyerMetaHash)) != keccak256(abi.encodePacked("")));

        transaction.approved = true;
        transaction.buyerMetaHash = buyerMetaHash;

        buyersDeposit = buyersDeposit.sub(transaction.price.sub(transaction.fee));

        uint256 feesDeposit = registry.feesDeposit();
        registry.setFeesDeposit(feesDeposit.sub(transaction.fee));

        registry.registerApprove(buyerAddress);
    }

    function rate(uint8 score) public onlyApproved onlyEnabled {
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

    function cancelRating() public onlyApproved onlyEnabled {
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
        uint256 _price,
        bool _purchased,
        bool _approved,
        bool _rated,
        uint8 _rating
    ) {
        Transaction storage transaction = transactions[buyerAddress];

        _publicKey = transaction.publicKey;
        _buyerMetaHash = transaction.buyerMetaHash;
        _price = transaction.price;
        _purchased = transaction.purchased;
        _approved = transaction.approved;
        _rated = transaction.rated;
        _rating = transaction.rating;
    }
}
