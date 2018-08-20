pragma solidity ^0.4.24;


contract Ownable {
    address public owner;
    address public ownerCandidate;

    event OwnerTransfer(address originalOwner, address currentOwner);

    modifier onlyOwner {
        require(msg.sender == owner, "Cannot call method restricted to owner only");
        _;
    }

    function proposeNewOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0) && newOwner != owner, "Invalid address");
        ownerCandidate = newOwner;
    }

    function acceptOwnerTransfer() public {
        require(msg.sender == ownerCandidate);
        emit OwnerTransfer(owner, ownerCandidate);
        owner = ownerCandidate;
    }
}
