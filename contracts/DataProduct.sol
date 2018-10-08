pragma solidity ^0.4.24;

import "./interface/DataProductInterface.sol";
import "./interface/OrderInterface.sol";
import "./interface/OrderFactoryInterface.sol";
import "./interface/RegistryInterface.sol";
import "./token/ERC20.sol";
import "./utils/AddressArrayRemover.sol";
import "./utils/Ownable.sol";
import "./utils/SafeMath.sol";
import "./utils/Versionable.sol";


contract DataProduct is Ownable, Versionable, DataProductInterface {
    using AddressArrayRemover for address[];
    using SafeMath for uint256;

    mapping(address => address) private buyersOrders;
    address[] private buyersAddresses;
    address[] private ordersAddresses;

    address private registryAddress;
    RegistryInterface private registry;

    address private orderFactoryAddress;
    OrderFactoryInterface private orderFactory;

    address private tokenAddress;
    ERC20 private token;

    string public sellerMetaHash;
    uint256 public price;
    uint256 public creationTimeStamp;
    uint8 public daysToDeliver;
    uint8 public daysToRate = 30;
    mapping(uint8 => uint256) private scoreCount;
    uint256 private rateCount;

    uint256 public buyersDeposit;

    bool public disabled = false;
    bool public kyc = false;

    modifier onlyBuyer() {
        require(buyersOrders[msg.sender] != address(0));
        _;
    }

    modifier onlyEnabled() {
        require(!disabled);
        _;
    }

    modifier isKycRequired() {
        if (kyc) {
            require(registry.isIdentifiedCustomer(msg.sender), "This file cannot be purchased by an unidentified customer");
        }
        _;
    }

    /**
        @param _registryAddress address of administrative contract
        @param _orderFactoryAddress address of factory for handling new orders
        @param _owner address of data product creator
        @param _tokenAddress address of currency token
        @param _sellerMetaHash hash to file within IPFS DB with data product meta information
        @param _price data product price in Repux Token
        @param _daysToDeliver days period in which seller is obligated to finalise transaction
        @param _version internal version for contract retrieved from factory
    */
    constructor(
        address _registryAddress,
        address _orderFactoryAddress,
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price,
        uint8 _daysToDeliver,
        uint16 _version
    )
        public
    {
        registryAddress = _registryAddress;
        registry = RegistryInterface(registryAddress);

        require(_price > registry.getOrderFee(_price), "Price should be greater than order fee value");

        orderFactoryAddress = _orderFactoryAddress;
        orderFactory = OrderFactoryInterface(orderFactoryAddress);

        owner = _owner;
        tokenAddress = _tokenAddress;
        token = ERC20(tokenAddress);
        sellerMetaHash = _sellerMetaHash;
        price = _price;
        daysToDeliver = _daysToDeliver;

        version = _version;
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

    /**
        @notice Make a purchase on behalf of specific buyer address. Data Product Contract receives tokens (price amount)
                and holds that amount in deposit until order is completed or canceled.
        @param _buyerAddress buyer address
        @param _buyerPublicKey a key used for encoding bought file which contains data product
        @return {
          "orderAddress": "The contract address to buyer's order"
        }
    */
    function purchaseFor(
        address _buyerAddress,
        string _buyerPublicKey
    )
        public
        isKycRequired
        onlyEnabled
        returns
    (
        address
    ) {
        require(buyersOrders[_buyerAddress] == address(0));

        uint256 fee = registry.getOrderFee(price);
        address orderAddress = orderFactory.createOrder(
            owner,
            _buyerAddress,
            _buyerPublicKey,
            now + daysToRate * 1 days,
            now + daysToDeliver * 1 days,
            price,
            fee
        );

        buyersOrders[_buyerAddress] = orderAddress;
        buyersAddresses.push(_buyerAddress);
        ordersAddresses.push(orderAddress);

        assert(token.transferFrom(msg.sender, this, price));

        buyersDeposit = buyersDeposit.add(price);

        registry.registerPurchase(_buyerAddress);

        return orderAddress;
    }

    /**
        @notice Make a purchase
        @param publicKey a key used for encoding bought file which contains data product
        @return {
          "orderAddress": "The contract address to buyer's order"
        }
    */
    function purchase(string publicKey) public isKycRequired onlyEnabled returns (address) {
        return purchaseFor(msg.sender, publicKey);
    }

    /**
        @notice Canceling of purchase is available after Order delivery period expires and Order is not yet finalised.
                Returns tokens to buyer and releases tokens from contract deposit by price amount.
    */
    function cancelPurchase() public onlyBuyer {
        OrderInterface order = OrderInterface(buyersOrders[msg.sender]);

        uint256 orderPrice = order.price();
        order.cancelPurchase();

        deleteOrder();
        assert(token.transfer(msg.sender, orderPrice));

        buyersDeposit = buyersDeposit.sub(orderPrice);

        registry.registerCancelPurchase(msg.sender);
    }

    function deleteOrder() private {
        buyersAddresses.removeByValue(msg.sender);
        ordersAddresses.removeByValue(buyersOrders[msg.sender]);

        delete buyersOrders[msg.sender];
    }

    /**
        @notice Perform order finalisation by data product owner. Handles fee transfer to Registry contract and
                releases tokens from contract deposit by price amount to be available for seller withdrawal.
        @param _buyerAddress buyer address
        @param _buyerMetaHash hash to IPFS file containing all necessary data to manage bought file
    */
    function finalise(address _buyerAddress, string _buyerMetaHash) public onlyOwner onlyEnabled {
        require(buyersOrders[_buyerAddress] != address(0));

        OrderInterface order = OrderInterface(buyersOrders[_buyerAddress]);
        order.finalise(_buyerMetaHash);
        uint256 orderFee = order.fee();

        if (orderFee > 0) {
            assert(token.transfer(registryAddress, orderFee));
        }

        buyersDeposit = buyersDeposit.sub(order.price());

        registry.registerFinalise(_buyerAddress);
    }

    /**
        @notice Perform order rating which is available right after order finalisation. Only buyer and only once has
                possibility to rate order in given period of time.
        @param score integer between 1 to 5
    */
    function rate(uint8 score) public onlyBuyer onlyEnabled {
        OrderInterface order = OrderInterface(buyersOrders[msg.sender]);
        order.rate(score);

        rateCount = rateCount.add(1);
        scoreCount[score] = scoreCount[score].add(1);

        registry.registerRating(msg.sender);
    }

    function disabled() public view returns (bool) {
        return disabled;
    }

    function setSellerMetaHash(string _sellerMetaHash) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_sellerMetaHash)) != keccak256(abi.encodePacked("")));

        sellerMetaHash = _sellerMetaHash;

        registry.registerUpdate(msg.sender);
    }

    function setPrice(uint256 newPrice) public onlyOwner onlyEnabled {
        require(newPrice > registry.getOrderFee(newPrice), "Price should be greater than order fee value");

        price = newPrice;

        registry.registerUpdate(msg.sender);
    }

    function setKyc(bool _kyc) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_kyc)) != keccak256(abi.encodePacked("")));

        kyc = _kyc;

        registry.registerUpdate(msg.sender);
    }

    function setDaysToDeliver(uint8 _daysToDeliver) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_daysToDeliver)) != keccak256(abi.encodePacked("")));

        daysToDeliver = _daysToDeliver;

        registry.registerUpdate(msg.sender);
    }

    function setDaysToRate(uint8 _daysToRate) public onlyOwner onlyEnabled {
        require(keccak256(abi.encodePacked(_daysToRate)) != keccak256(abi.encodePacked("")));

        daysToRate = _daysToRate;

        registry.registerUpdate(msg.sender);
    }

    function getOrderFor(address _address) public view returns (address) {
        return buyersOrders[_address];
    }

    function getOrder() public view returns (address) {
        return getOrderFor(msg.sender);
    }

    function getBuyersAddresses() public view returns (address[]) {
        return buyersAddresses;
    }

    function getOrdersAddresses() public view returns (address[]) {
        return ordersAddresses;
    }
}
