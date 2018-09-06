pragma solidity ^0.4.24;


contract RegistryInterface {
    function isDataProduct(address _address) public view returns (bool);
    function deleteDataProduct(address _address) public returns (bool);
    function isIdentifiedCustomer(address _address) public view returns (bool);
    function registerPurchase(address sender) external;
    function registerCancelPurchase(address sender) external;
    function registerFinalise(address sender) external;
    function registerUpdate(address sender) external;
    function registerRating(address sender) external;
}
