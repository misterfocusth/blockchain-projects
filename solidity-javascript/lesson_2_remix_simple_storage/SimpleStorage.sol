// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    // boolean , uint (positive numbers), int (neg & pos numbers), address, bytes

    // bool hasFavoriteNumber = true;
    // uint256 favoriteNumber = 5;
    // string favoriteNumberInText = "Five";
    // int256 favoriteInt = -5;
    // address myAddress = 0xf466e7cE6B06f9b3071557A790Bd45F051C1C60A;
    // bytes32 favoriteBytes = "cat";

    uint256 favoriteNumber; // Storage

    struct People {
        uint256 favoriteNumber;
        string name;
    }

    People public owner = People({
        favoriteNumber: 65070219,
        name: "Sila Pakdeewong"
    });

    People[] public people;

    mapping(string => uint256) public nameToFavoriteNumber;

    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    function retrieve() public view returns(uint256) {
        return favoriteNumber;
    }

    // View, Pure = Transaction Fee Free, Can't make any modification. (Read Only)
    function getFavoriteNumber() public view returns(uint256) {
        return favoriteNumber;
    }

    function getSomeComputation() public pure returns(uint256) {
        return 99 + 99;
    }

    // Calldata, Memory, Storage
    // Data Location Required For: Array, Struct, Mappng Type.

    // Calldata = Exist temporary, during transactions. (Temp, Can't reassign)
    // Memory = Exist temporary, during transactions. (Temp, Can reassign)
    // Storage = Exist even transaction completed. (Persistant)

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        People memory newPerson = People(_favoriteNumber, _name);
        people.push(newPerson);
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}