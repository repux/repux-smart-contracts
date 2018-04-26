pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./Ownable.sol";


contract Feeable is Ownable {
    using SafeMath for uint256;

    uint256 public fileFlatFee = 0;
    uint256 public fileStorageFee = 0;
    uint256 public transactionFlatFee = 0;
    uint256 public transactionPercentageFee = 0;
    uint256 public developerFlatFee = 0;
    uint256 public developerPercentageFee = 0;
    address public feeAdmin;
    address public feeAdminCandidate;

    event FeeAdminTransfer(address currentAdmin, address newAdmin);

    modifier onlyFeeAdmin {
        require(msg.sender == feeAdmin);
        _;
    }

    function proposeNewFeeAdmin(address newFeeAdmin) public onlyOwner {
        require(newFeeAdmin != address(0) && newFeeAdmin != feeAdmin);

        feeAdminCandidate = newFeeAdmin;
    }

    function acceptFeeAdminTransfer() public {
        require(msg.sender == feeAdminCandidate);

        emit FeeAdminTransfer(feeAdmin, feeAdminCandidate);
        feeAdmin = feeAdminCandidate;
    }

    function setFileFlatFee(uint256 fee) external onlyFeeAdmin {
        fileFlatFee = fee;
    }

    function setFileStorageFee(uint256 fee) external onlyFeeAdmin {
        fileStorageFee = fee;
    }

    function setTransactionFlatFee(uint256 fee) external onlyFeeAdmin {
        transactionFlatFee = fee;
    }

    function setTransactionPercentageFee(uint256 fee) external onlyFeeAdmin {
        transactionPercentageFee = fee;
    }

    function setDeveloperFlatFee(uint256 fee) external onlyFeeAdmin {
        developerFlatFee = fee;
    }

    function setDeveloperPercentageFee(uint256 fee) external onlyFeeAdmin {
        developerPercentageFee = fee;
    }

    function getTransactionFee(uint256 price) public view returns (uint256) {
        return transactionFlatFee.add(price.mul(transactionPercentageFee).div(100));
    }
}
