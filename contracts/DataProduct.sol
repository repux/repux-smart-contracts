import "./SafeMath.sol";
import "./ERC20.sol";
import "./Ownable.sol";
import "./Registry.sol";

contract DataProduct is Ownable {
	using SafeMath for uint256;
	address public registryAddress;
	Registry public registry;
	address public tokenAddress;
	ERC20 private token;
	string public name;
	string public description;
	string public ipfsHash;
	string public category;
	uint256 public price;
	uint256 public size;
	uint256 public creationTimeStamp;
	mapping (address => bool) public ownership;
	mapping (address => bool) public rated;
	mapping (address => bool) public ratings;
	uint256 public purchaseCount;
	uint8 public minScore = 0;
	uint8 public maxScore = 5;
	mapping (uint8 => uint256) public scoreCount;
	mapping (address => uint8) private userRatings;
	mapping (address => bool) private userRated;
	uint256 public rateCount;
	uint256 private ownerDeposit;
	event Purchase(address purchaser, address recipient);
	event DataUpdate(string originalHash, string newHash);
	event PriceUpdate(uint256 originalPrice, uint256 newPrice);

	modifier onlyRegistry() {
		require(msg.sender == registryAddress);
		_;
	}

	function DataProduct(address _owner, address _tokenAddress, string _name, 
		string _description, string _ipfsHash, string _category, uint256 _price,
		uint256 _size) public {
		registryAddress = msg.sender;
		registry = Registry(registryAddress);
		owner = _owner;
		ownership[owner] = true;
		tokenAddress = _tokenAddress;
		token = ERC20(tokenAddress);
		name = _name;
		description = _description;
		ipfsHash = _ipfsHash;
		category = _category;
		price = _price;
		size = _size;
		creationTimeStamp = block.timestamp;
	}

	function ownerWithdraw(uint256 amount) public onlyOwner {
		require(amount <= ownerDeposit);
		ownerDeposit = ownerDeposit.sub(amount);
		assert(token.transfer(owner, amount));
	}

	function ownerWithdrawAll() public onlyOwner {
		require(ownerDeposit > 0);
		uint256 amount = ownerDeposit;
		ownerDeposit = 0;
		assert(token.transfer(owner, amount));
	}

	function getOwnerDeposit() public constant onlyOwner returns(uint256) {
		return ownerDeposit;
	}

	function setPrice(uint256 newPrice) public onlyOwner {
		PriceUpdate(price, newPrice);
		price = newPrice;		
	}

	function setSize(uint256 newSize) public onlyOwner {
		size = newSize;
	}

	function setName(string newName) public onlyOwner {
		require(keccak256(newName) != keccak256(""));
		name = newName;
	}

	function setDescription(string newDescription) public onlyOwner {
		description = newDescription;
	}

	function setCategory(string newCategory) public onlyOwner {
		category = newCategory;
	}

	function purchaseFor(address recipient) public {
		require(!getOwnership(recipient));
		ownership[recipient] = true;
		assert(token.transferFrom(msg.sender, owner, price));
		purchaseCount = purchaseCount.add(1);
		Purchase(msg.sender, recipient);
		registry.registerUserPurchase(recipient);
	}

	function purchase() public {
		purchaseFor(msg.sender);
	}

	function rate(uint8 score) public {
		require(getOwnership(msg.sender));
		require(score >= minScore && score <= maxScore);
		if (userRated[msg.sender]) {
			uint8 originalScore = userRatings[msg.sender];
			require(score != originalScore);
			scoreCount[originalScore] = scoreCount[originalScore].sub(1);
		} else {
			rateCount = rateCount.add(1);
			userRated[msg.sender] = true;
		}
		scoreCount[score] = scoreCount[score].add(1);
		userRatings[msg.sender] = score;
		registry.registerRating(msg.sender, score);
	}

	function cancelRating() public {
		require(userRated[msg.sender]);
		userRated[msg.sender] = false;
		uint8 score = userRatings[msg.sender];
		scoreCount[score] = scoreCount[score].sub(1);
		userRatings[msg.sender] = 0;
		rateCount = rateCount.sub(1);
		registry.registerCancelRating(msg.sender);
	}

	function setData(string _ipfsHash) public onlyOwner {
		require(keccak256(_ipfsHash) != keccak256(""));
		DataUpdate(ipfsHash, _ipfsHash);
		ipfsHash = _ipfsHash;
	}

	
	function getOwnership(address addr) public constant returns(bool) {
		return ownership[addr];
	}
	
	function getTotalRating() public constant returns(uint256) {
		uint256 total = 0;
		for (uint8 score=minScore; score<=maxScore; score++) {
			total = total.add(scoreCount[score].mul(score));
		}
		return total;
	}

	function getDataProductFor(address addr) public constant returns (
		//address _this,
 		address _owner,
 		string _name, 
 		string _description, 
 		string _ipfsHash, 
 		string _category,
 		uint256 _price,
 		uint256 _size,
 		uint256 _totalRating,
 		uint256 _rateCount,
 		uint256 _purchaseCount,
 		bool _ownership
 	) {
 		//_this = this;
 		_owner = owner;
 		_name = name;
 		_description = description;
 		_ipfsHash = ipfsHash;
 		_category = category;
 		_size = size;
 		_price = price;
 		_totalRating = getTotalRating();
 		_rateCount = rateCount;
 		_purchaseCount = purchaseCount;
 		_ownership = getOwnership(addr);
	}

	function getDataProduct() public constant returns (
		//address _this,
 		address _owner,
 		string _name, 
 		string _description,  
 		string _ipfsHash,
 		string _category,
 		uint256 _price,
 		uint256 _size,
 		uint256 _totalRating,
 		uint256 _rateCount,
 		uint256 _purchaseCount,
 		bool _ownership
 	) {
		return getDataProductFor(msg.sender);
 	}
   

}