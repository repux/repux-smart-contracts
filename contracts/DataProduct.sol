pragma solidity 0.4.24;

import "./AddressArrayRemover.sol";
import "./DataProductInterface.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./RegistryInterface.sol";
import "./SafeMath.sol";
import "./OrderInterface.sol";
import "./OrderFactoryInterface.sol";


contract DataProduct is Ownable, DataProductInterface {
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

    constructor(
        address _registryAddress,
        address _orderFactoryAddress,
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price,
        uint8 _daysToDeliver
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

    function purchase(string publicKey) public isKycRequired onlyEnabled returns (address) {
        return purchaseFor(msg.sender, publicKey);
    }

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
