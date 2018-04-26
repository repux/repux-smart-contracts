import "./SafeMath.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./DataProduct.sol";

contract Registry is Ownable {
	using SafeMath for uint256;
	address public tokenAddress;
	address[] public dataProducts;
	mapping (address => address[]) public dataCreated;
	mapping (address => address[]) public dataPurchased;
	mapping (address => bool) public isDataProduct;
	event CreateDataProduct(address dataProduct, string ipfsHash);
	event PurchaseDataProduct(address dataProduct, address buyer);
	event RateDataProduct(address dataProduct, address rater, uint8 score);
	event CancelRating(address dataProduct, address rater);

	modifier onlyDataProduct {
		require(isDataProduct[msg.sender]);
		_;
	}

	function Registry(address _tokenAddress) {
		owner = msg.sender;
		tokenAddress = _tokenAddress;
	}

	function deleteDataProduct(address addr) public onlyOwner returns(bool) {
		bool deleted = false;
		uint256 deletedIndex = 0;

		for (; deletedIndex<dataProducts.length; deletedIndex++) {
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

	function createDataProduct(string _name, string _description, 
		string ipfsHash, string category, uint256 _price, uint256 size
		) public returns(address){
		address newDataProduct = new DataProduct(msg.sender, tokenAddress, _name, 
			_description, ipfsHash, category, _price, size);
		dataProducts.push(newDataProduct);
		dataCreated[msg.sender].push(newDataProduct);
		isDataProduct[newDataProduct] = true;
		CreateDataProduct(newDataProduct, ipfsHash);
		return newDataProduct;
	}

	function registerUserPurchase(address user) public onlyDataProduct {
		dataPurchased[user].push(msg.sender);
		PurchaseDataProduct(msg.sender, user);
	}

	function registerRating(address user, uint8 score) public onlyDataProduct {
		RateDataProduct(msg.sender, user, score);
	}

	function registerCancelRating(address user) public onlyDataProduct {
		CancelRating(msg.sender, user);
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