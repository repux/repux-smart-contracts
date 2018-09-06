pragma solidity ^0.4.24;

import "../interface/FeeStakesInterface.sol";
import "../storage/EternalStorageInterface.sol";
import "../utils/Ownable.sol";
import "../utils/SafeMath.sol";
import "../utils/Versionable.sol";


contract FeeStakes is FeeStakesInterface, Ownable, Versionable {
    using SafeMath for uint256;

    address private feeStakesStorageAddress;
    EternalStorageInterface private feeStakesStorage;

    string private fileFlatFeeKey = "fileFlatFee";
    string private fileStorageFeeKey = "fileStorageFee";
    string private orderFlatFeeKey = "orderFlatFee";
    string private orderPercentageFeeKey = "orderPercentageFee";
    string private developerFlatFeeKey = "developerFlatFee";
    string private developerPercentageFeeKey = "developerPercentageFee";
    address public feeAdmin;
    address public feeAdminCandidate;

    event FeeAdminTransfer(address currentAdmin, address newAdmin);

    modifier onlyFeeAdmin {
        require(msg.sender == feeAdmin);
        _;
    }

    constructor(
        address _owner,
        address _storageAddress,
        uint16 _version
    )
    public
    {
        require(
            _owner != address(0) &&
            _storageAddress != address(0),
            "Incorrect initial addresses"
        );

        owner = _owner;
        version = _version;
        feeStakesStorageAddress = _storageAddress;
        feeStakesStorage = EternalStorageInterface(feeStakesStorageAddress);
    }

    function proposeNewFeeAdmin(address newFeeAdmin) public onlyOwner {
        require(newFeeAdmin != address(0) && newFeeAdmin != feeAdmin);

        feeAdminCandidate = newFeeAdmin;
    }

    function acceptFeeAdminTransfer() public {
        require(msg.sender == feeAdminCandidate, "Cannot call method restricted to candidate only");

        emit FeeAdminTransfer(feeAdmin, feeAdminCandidate);
        feeAdmin = feeAdminCandidate;
    }

    function setFileFlatFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(fileFlatFeeKey)), fee);
    }

    function getFileFlatFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(fileFlatFeeKey)));
    }

    function setFileStorageFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(fileStorageFeeKey)), fee);
    }

    function getFileStorageFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(fileStorageFeeKey)));
    }

    function setOrderFlatFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(orderFlatFeeKey)), fee);
    }

    function getOrderFlatFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(orderFlatFeeKey)));
    }

    function setOrderPercentageFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(orderPercentageFeeKey)), fee);
    }

    function getOrderPercentageFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(orderPercentageFeeKey)));
    }

    function setDeveloperFlatFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(developerFlatFeeKey)), fee);
    }

    function getDeveloperFlatFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(developerFlatFeeKey)));
    }

    function setDeveloperPercentageFee(uint256 fee) external onlyFeeAdmin {
        feeStakesStorage.setUint(keccak256(abi.encodePacked(developerPercentageFeeKey)), fee);
    }

    function getDeveloperPercentageFee() public view returns (uint256) {
        return feeStakesStorage.getUint(keccak256(abi.encodePacked(developerPercentageFeeKey)));
    }

    function getOrderFee(uint256 price) public view returns (uint256) {
        uint256 orderFlatFee = getOrderFlatFee();
        uint256 orderPercentageFee = getOrderPercentageFee();

        return orderFlatFee.add(price.mul(orderPercentageFee).div(100));
    }
}
