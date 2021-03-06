pragma solidity ^0.4.24;

import "./token/StandardToken.sol";
import "./utils/Ownable.sol";


contract DemoToken is StandardToken, Ownable {
    uint8 public decimals = 18;

    event Issue(address recipient, uint256 amount);

    constructor() public {
        owner = msg.sender;
        balances[msg.sender] = (10 ** uint256(decimals)).mul(100);
    }

    function issue(address recipient, uint256 amount) public onlyOwner {
        balances[recipient] = balances[recipient].add(amount);
        totalSupply = totalSupply.add(amount);
        emit Issue(recipient, amount);
    }
}
