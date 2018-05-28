pragma solidity 0.4.24;

import "./DataStore.sol";
import "./SafeMath.sol";
import "./DataProduct.sol";


library TransactionLibrary {
    using SafeMath for uint256;

    function transactionCount(address transactionStoreAddress) public view returns (uint count) {
        return DataStore(transactionStoreAddress).count();
    }

    function createTransaction(
        address transactionStoreAddress,
        uint256 _dataProductIndex,
        address _wallet,
        string _publicKey,
        uint256 _price,
        uint256 _fee,
        bool _purchased
    )
        public
    {
        var transactionStore = DataStore(transactionStoreAddress);
        transactionStore.addNew();
        // TODO Find if addNew can be called simultaneously. If yes, the below index will not point to correct entry.
        var index = transactionStore.count();

        transactionStore.setIntValue(keccak256('dataProductIndex', index), _dataProductIndex);
        transactionStore.setAddressValue(keccak256('wallet', index), _wallet);
        transactionStore.setStringValue(keccak256('publicKey', index), _publicKey);
        transactionStore.setStringValue(keccak256('buyerMetaHash', index), "");
        transactionStore.setIntValue(keccak256('price', index), _price);
        transactionStore.setIntValue(keccak256('fee', index), _fee);
        transactionStore.setBoolValue(keccak256('purchased', index), _purchased);
        transactionStore.setBoolValue(keccak256('approved', index), false);
        transactionStore.setBoolValue(keccak256('rated', index), false);
        transactionStore.setIntValue(keccak256('rating', index), 0);

        transactionStore.setBytes32Index(
            'buyerDataProduct',
            keccak256(abi.encodePacked(_wallet, _dataProductIndex)),
            index
        );
    }

    function getTransaction(address transactionStoreAddress, uint id)
        public view
        returns (
            uint index,
            string publicKey,
            string buyerMetaHash,
            uint price,
            uint fee,
            bool purchased,
            bool approved,
            bool rated,
            uint rating
        )
    {
        var transactionStore = DataStore(transactionStoreAddress);

        require(id > 0 && id < transactionStore.count());

        index = id;
        publicKey = transactionStore.getStringValue(keccak256('publicKey', index));
        buyerMetaHash = transactionStore.getStringValue(keccak256('buyerMetaHash', index));
        price = transactionStore.getIntValue(keccak256('price', index));
        fee = transactionStore.getIntValue(keccak256('fee', index));
        purchased = transactionStore.getBoolValue(keccak256('purchased', index));
        approved = transactionStore.getBoolValue(keccak256('approved', index));
        rated = transactionStore.getBoolValue(keccak256('rated', index));
        rating = transactionStore.getIntValue(keccak256('rating', index));
    }

    function approve(address transactionStoreAddress, uint id, string buyerMetaHash) public {
        var transactionStore = DataStore(transactionStoreAddress);

        require(id > 0 && id < transactionStore.count());

        purchased = transactionStore.getBoolValue(keccak256('purchased', index));
        approved = transactionStore.getBoolValue(keccak256('approved', index));
        require(purchased && !approved);
        require(keccak256(abi.encodePacked(buyerMetaHash)) != keccak256(abi.encodePacked("")));

        transactionStore.setBoolValue(keccak256('approved', index), true);
        transactionStore.setStringValue(keccak256('buyerMetaHash', index), buyerMetaHash);
    }
}
