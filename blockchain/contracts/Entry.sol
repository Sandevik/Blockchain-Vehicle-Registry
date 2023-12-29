//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Entry {

    enum Type {
        CAR,
        BOAT,
        MOTORCYCLE,
        BUS,
        TRUCK
    }

    mapping(string => Item) public items;
    uint256 itemsCount = 0;

    struct Item {
        string[] images;
        string make;
        string model;
        Type Type;
        string licensePlateNr;
        uint8 allowedPassengers;
        uint16 year;
        string color;
        address owner;
        uint16 prevOwnersCount;
    }

    constructor() {}

    function newEntry(address _owner, string[] memory _images, string memory _make, string memory _model, Type _type, string memory _licensePlateNr, uint8 _allowedPassengers, uint16 _year, string memory _color) external payable {
        Item memory item = Item({
            images: _images,
            make: _make,
            model: _model,
            licensePlateNr: _licensePlateNr,
            allowedPassengers: _allowedPassengers,
            Type: _type,
            year: _year,
            color: _color,
            owner: _owner,
            prevOwnersCount: 1
        });
        item.owner = _owner;
        items[_licensePlateNr] = item;
        itemsCount += 1;
    }

    function transfer(string memory _licensePlateNr, address _currentOwner, address _to) external payable onlyOwner(_licensePlateNr, _currentOwner) {
        items[_licensePlateNr].owner = _to;
        items[_licensePlateNr].prevOwnersCount += 1;
    }

    function viewEntry(string memory _licensePlateNr) external view returns(Item memory) {
        return items[_licensePlateNr];
    }

    function burnEntry(string memory _licensePlateNr) external payable {
        delete items[_licensePlateNr];
        itemsCount -= 1;
    }

    function editLicensePlate(string memory _currentLicensePlateNr, string memory _newLicensePlateNr, address _owner) external onlyOwner(_currentLicensePlateNr, _owner) {
        require(keccak256(bytes(_newLicensePlateNr)) != keccak256(""), "ERROR: New license plate cannot be empty.");
        string memory current = items[_newLicensePlateNr].licensePlateNr;
        require(keccak256(bytes(current)) == keccak256("") , "ERROR: license plate already in use.");
        Item memory item = items[_currentLicensePlateNr];
        delete items[_currentLicensePlateNr];
        item.licensePlateNr = _newLicensePlateNr;
        items[_newLicensePlateNr] = item;
    }

    function getCount() external view returns(uint256) {
        return itemsCount;
    }

     // ----------------- Helper functions -------------------------------

    function stringToUint(string memory s) private pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function getSlice(uint256 begin, uint256 end, string memory text) private pure returns (string memory) {
        bytes memory a = new bytes(end-begin+1);
        for(uint i=0;i<=end-begin;i++){
            a[i] = bytes(text)[i+begin-1];
        }
        return string(a);    
    }

    // -------------- Modifiers ------------------------------------------------

    modifier validateLicensePlateNr(string memory _licensePlateNr) {
        bytes memory b = bytes(_licensePlateNr);
        require(bytes(_licensePlateNr).length == 6, "ERROR: License plate length is invalid.");

        require(
            b.length == 6 
            && (stringToUint(getSlice(0,1, _licensePlateNr)) >= 65 && stringToUint(getSlice(0,1, _licensePlateNr)) <= 90 || stringToUint(getSlice(0,1, _licensePlateNr)) == 196 || stringToUint(getSlice(0,1, _licensePlateNr)) == 197 || stringToUint(getSlice(0,1, _licensePlateNr)) == 214) 
            && (stringToUint(getSlice(1,2, _licensePlateNr)) >= 65 && stringToUint(getSlice(1,2, _licensePlateNr)) <= 90 || stringToUint(getSlice(1,2, _licensePlateNr)) == 196 || stringToUint(getSlice(1,2, _licensePlateNr)) == 197 || stringToUint(getSlice(1,2, _licensePlateNr)) == 214) 
            && (stringToUint(getSlice(2,3, _licensePlateNr)) >= 65 && stringToUint(getSlice(2,3, _licensePlateNr)) <= 90 || stringToUint(getSlice(2,3, _licensePlateNr)) == 196 || stringToUint(getSlice(2,3, _licensePlateNr)) == 197 || stringToUint(getSlice(2,3, _licensePlateNr)) == 214) 
            && (stringToUint(getSlice(3,4, _licensePlateNr)) >= 48 && stringToUint(getSlice(3,4, _licensePlateNr)) <= 57)
            && (stringToUint(getSlice(4,5, _licensePlateNr)) >= 48 && stringToUint(getSlice(4,5, _licensePlateNr)) <= 57)
            && ((stringToUint(getSlice(5,6, _licensePlateNr)) >= 65 && stringToUint(getSlice(5,6, _licensePlateNr)) <= 90 || stringToUint(getSlice(5,6, _licensePlateNr)) == 196 || stringToUint(getSlice(5,6, _licensePlateNr)) == 197 || stringToUint(getSlice(5,6, _licensePlateNr)) == 214) || (stringToUint(getSlice(5,6, _licensePlateNr)) >= 48 && stringToUint(getSlice(5,6, _licensePlateNr)) <= 57))
            , "ERROR: Invalid license plate format, correct format: ABC123 or ABC12D");
        _;
    }

    modifier onlyOwner(string memory _licensePlateNr, address _currentOwner) {
        require(_currentOwner == items[_licensePlateNr].owner, "Error: You do not own this item.");
        _;
    }

}