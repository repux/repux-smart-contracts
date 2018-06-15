pragma solidity 0.4.24;

import "./SafeMath.sol";


library AddressArrayRemover {
    using SafeMath for uint256;

    function indexOf(address[] array, address value) public pure returns (uint) {
        uint index = array.length;

        for (uint i = 0; i < array.length; i++) {
            if (value == array[i]) {
                index = i;
                break;
            }
        }

        return index;
    }

    function removeByValue(address[] storage array, address value) public {
        uint index = indexOf(array, value);

        removeByIndex(array, index);
    }

    function removeByIndex(address[] storage array, uint index) public {
        require(index >= 0 && index < array.length, "Out of array range");

        array[index] = array[array.length.sub(1)];
        array.length = array.length.sub(1);
    }
}
