pragma solidity 0.4.24;

import "./FeeableInterface.sol";
import "./Ownable.sol";
import "./SafeMath.sol";


contract Feeable is Ownable, FeeableInterface {
    using SafeMath for uint256;

    uint256 public fileFlatFee = 0;
    uint256 public fileStorageFee = 0;
    uint256 public orderFlatFee = 0;
    uint256 public orderPercentageFee = 0;
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

    function setOrderFlatFee(uint256 fee) external onlyFeeAdmin {
        orderFlatFee = fee;
    }

    function setOrderPercentageFee(uint256 fee) external onlyFeeAdmin {
        orderPercentageFee = fee;
    }

    function setDeveloperFlatFee(uint256 fee) external onlyFeeAdmin {
        developerFlatFee = fee;
    }

    function setDeveloperPercentageFee(uint256 fee) external onlyFeeAdmin {
        developerPercentageFee = fee;
    }

    function getOrderFee(uint256 price) public view returns (uint256) {
        return orderFlatFee.add(price.mul(orderPercentageFee).div(100));
    }
}
