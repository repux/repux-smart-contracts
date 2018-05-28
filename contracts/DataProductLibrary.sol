pragma solidity 0.4.24;

import "./DataStore.sol";
import "./TransactionLibrary.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./Registry.sol";


library DataProductLibrary {
    using SafeMath for uint256;
    using TransactionLibrary for address;

    uint8 constant minScore = 0;
    uint8 constant maxScore = 5;

    function dataProductCount(address dataProductStoreAddress) public view returns (uint count) {
        return DataStore(dataProductStoreAddress).count();
    }

    function createDataProduct(
        address dataProductStoreAddress,
        address _owner,
        address _tokenAddress,
        string _sellerMetaHash,
        uint256 _price
    )
        public
    {
        var dataProductStore = DataStore(dataProductStoreAddress);
        dataProductStore.addNew();
        // TODO Find if addNew can be called simultaneously. If yes, the below index will not point to correct entry.
        var index = dataProductStore.count();

        Registry memory registry = Registry(msg.sender);

        require(_price > registry.getTransactionFee(_price), "Price should be greater than transaction fee value");

        dataProductStore.setAddressValue(keccak256('registryAddress', index), msg.sender);
        dataProductStore.setAddressValue(keccak256('owner', index), _owner);
        dataProductStore.setAddressValue(keccak256('tokenAddress', index), _tokenAddress);
        dataProductStore.setStringValue(keccak256('sellerMetaHash', index), _sellerMetaHash);
        dataProductStore.setIntValue(keccak256('price', index), _price);
        dataProductStore.setIntValue(keccak256('creationTimeStamp', index), block.timestamp);
        dataProductStore.setIntValue(keccak256('rateCount', index), 0);
        dataProductStore.setIntValue(keccak256('buyersDeposit', index), 0);

        dataProductStore.setBytes32Index(
            'owner',
            keccak256(abi.encodePacked(_owner, _dataProductIndex)),
            index
        );
    }

    function getDataProduct(address dataProductStoreAddress, uint id)
        public view
        returns (
            uint index,
            address registryAddress,
            address owner,
            address tokenAddress,
            string sellerMetaHash,
            uint price,
            uint creationTimeStamp
        )
    {
        var dataProductStore = DataStore(dataProductStoreAddress);

        if (id < 1 || id > dataProductStore.count()) {
            return;
        }

        index = id;
        registryAddress = dataProductStore.getAddressValue(keccak256('registryAddress', index));
        owner = dataProductStore.getAddressValue(keccak256('owner', index), _owner);
        tokenAddress = dataProductStore.getAddressValue(keccak256('tokenAddress', index));
        sellerMetaHash = dataProductStore.getStringValue(keccak256('sellerMetaHash', index));
        price = dataProductStore.getIntValue(keccak256('price', index), _price);
        creationTimeStamp = dataProductStore.getIntValue(keccak256('creationTimeStamp', index));
    }

    function rate(address dataProductStoreAddress, address transactionStoreAddress, uint id, uint8 score) public onlyApproved {
        require(score >= minScore && score <= maxScore);

        var dataProductStore = DataStore(dataProductStoreAddress);

        if (id < 1 || id > dataProductStore.count()) {
            return;
        }

        index = id;

        var transactionStore = DataStore(transactionStoreAddress);
        uint transactionIndex = transactionStore.getBytes32Index(
            'buyerDataProduct',
            keccak256(abi.encodePacked(msg.sender, index))
        );

        if (transactionStore.getBoolValue(keccak256('rated', transactionIndex))) {
            uint8 originalScore = transactionStore.getIntValue(keccak256('rating', transactionIndex));
            require(score != originalScore);

            uint originalScoreCount = dataProductStore.getMappingIntValue(keccak256('scoreCount', index), originalScore);
            dataProductStore.setMappingIntValue(keccak256('scoreCount', index), originalScore, originalScoreCount.sub(1));
        } else {
            uint rateCount = dataProductStore.getIntValue(keccak256('rateCount', index));
            dataProductStore.setIntValue(keccak256('rateCount', index), rateCount.add(1));
            transactionStore.setBoolValue(keccak256('rated', transactionIndex), true);
        }

        uint scoreCount = dataProductStore.getMappingIntValue(keccak256('scoreCount', index), score);
        dataProductStore.setMappingIntValue(keccak256('scoreCount', index), score, scoreCount.add(1));
        transactionStore.setIntValue(keccak256('rating', transactionIndex), score);

        registry.registerRating(msg.sender, score);
    }

    function cancelRating(address dataProductStoreAddress, address transactionStoreAddress, uint id) public onlyApproved {
        var dataProductStore = DataStore(dataProductStoreAddress);

        if (id < 1 || id > dataProductStore.count()) {
            return;
        }

        index = id;

        var transactionStore = DataStore(transactionStoreAddress);
        uint transactionIndex = transactionStore.getBytes32Index(
            'buyerDataProduct',
            keccak256(abi.encodePacked(msg.sender, index))
        );

        require(transactionStore.getBoolValue(keccak256('rated', transactionIndex)));

        uint8 score = transactionStore.getIntValue(keccak256('rating', transactionIndex));
        scoreCount[score] = scoreCount[score].sub(1);
        uint rateCount = dataProductStore.getIntValue(keccak256('rateCount', index));
        dataProductStore.setIntValue(keccak256('rateCount', index), rateCount.sub(1));
        transactionStore.setBoolValue(keccak256('rated', transactionIndex), false);
        transactionStore.setIntValue(keccak256('rating', transactionIndex), 0);

        registry.registerCancelRating(msg.sender);
    }

    function getTotalRating() public constant returns (uint256) {
        uint256 total = 0;

        for (uint8 score = minScore; score <= maxScore; score++) {
            total = total.add(scoreCount[score].mul(score));
        }

        return total;
    }
}
