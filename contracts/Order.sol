pragma solidity ^0.4.24;

import "./interface/DataProductInterface.sol";
import "./interface/OrderInterface.sol";
import "./utils/Ownable.sol";
import "./utils/SafeMath.sol";
import "./utils/Versionable.sol";


contract Order is Ownable, Versionable, OrderInterface {
    using SafeMath for uint256;

    uint8 constant private minScore = 1;
    uint8 constant private maxScore = 5;

    address private dataProductAddress;
    DataProductInterface private dataProduct;

    address public buyerAddress;
    string public buyerPublicKey;
    string public buyerMetaHash;
    uint256 public creationTimeStamp;
    uint256 public rateDeadline;
    uint256 public deliveryDeadline;
    uint256 public price;
    uint256 public fee;
    bool public purchased;
    bool public finalised;
    bool public rated;
    uint8 public rating;

    modifier onlyDataProduct() {
        require(msg.sender == dataProductAddress);
        _;
    }

    modifier onlyFinalised() {
        require(finalised);
        _;
    }

    constructor(
        address _dataProductAddress,
        address _owner,
        address _buyerAddress,
        string _buyerPublicKey,
        uint256 _rateDeadline,
        uint256 _deliveryDeadline,
        uint256 _price,
        uint256 _fee,
        uint16 _version
    )
        public
    {
        require(_owner != _buyerAddress);
        require(bytes(_buyerPublicKey).length != 0);

        dataProductAddress = _dataProductAddress;
        dataProduct = DataProductInterface(dataProductAddress);

        owner = _owner;
        buyerAddress = _buyerAddress;
        buyerPublicKey = _buyerPublicKey;
        rateDeadline = _rateDeadline;
        deliveryDeadline = _deliveryDeadline;
        price = _price;
        fee = _fee;
        purchased = true;

        version = _version;
        creationTimeStamp = now;
    }

    function kill() private onlyDataProduct {
        selfdestruct(owner);
    }

    function cancelPurchase() external onlyDataProduct {
        require(purchased && !finalised && (now >= deliveryDeadline || dataProduct.disabled()));

        kill();
    }

    function finalise(string _buyerMetaHash) external onlyDataProduct {
        require(purchased && !finalised);
        require(keccak256(abi.encodePacked(_buyerMetaHash)) != keccak256(abi.encodePacked("")));

        finalised = true;
        buyerMetaHash = _buyerMetaHash;
    }

    function rate(uint8 score) external onlyFinalised onlyDataProduct {
        require(score >= minScore && score <= maxScore);
        require(!rated && now <= rateDeadline);

        rated = true;
        rating = score;
    }

    function price() public view returns (uint256) {
        return price;
    }

    function fee() public view returns (uint256) {
        return fee;
    }
}
