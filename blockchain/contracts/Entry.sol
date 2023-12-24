//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Entry {

    mapping(string => Item) public items;
    uint256 itemsCount = 0;

    struct Item {
        string[] images;
        string make;
        string model;
        string Type;
        string licensePlateNr;
        uint8 allowedPassengers;
        uint16 year;
        string color;
        address owner;
        uint16 prevOwnersCount;
    }

    constructor() payable {}

    function newEntry(address _owner, string[] memory _images, string memory _make, string memory _model, string memory _type, string memory _licensePlateNr, uint8 _allowedPassengers, uint16 _year, string memory _color) external payable {
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

    function getCount() external view returns(uint256) {
        return itemsCount;
    }

    modifier onlyOwner(string memory _licensePlateNr, address _currentOwner) {
        require(_currentOwner == items[_licensePlateNr].owner, "Error: You do not own this item.");
        _;
    }

}