pragma solidity ^0.4.24;

import "./utils/Ownable.sol";


contract AliasList is Ownable {
    struct Alias {
        string nick;
        string description;
    }

    mapping(address => Alias) private aliases;
    mapping(bytes32 => bool) private existingNicks;

    constructor() public {
        owner = msg.sender;
    }

    function setAlias(string _nick, string _description) public {
        bytes32 _encodedNick = keccak256(abi.encodePacked(_nick));

        require(_encodedNick != keccak256(abi.encodePacked("")), "Nick cannot be empty!");
        require(!existingNicks[_encodedNick], "Nick already exists!");

        Alias storage alias = aliases[msg.sender];

        existingNicks[_encodedNick] = true;
        delete existingNicks[keccak256(abi.encodePacked(alias.nick))];

        alias.nick = _nick;
        alias.description = _description;
    }

    function getAlias() public view returns (string _nick, string _description) {
        (_nick, _description) = getAliasFor(msg.sender);
    }

    function getAliasFor(address _address) public view returns (string _nick, string _description) {
        Alias memory alias = aliases[_address];

        _nick = alias.nick;
        _description = alias.description;
    }
}
