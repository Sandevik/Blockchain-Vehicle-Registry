//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import "./Entry.sol";

contract Registry {

    //create instance of Entry contract.
    Entry private entry = new Entry();
    
    //the superUser
    address private superUser;

    //Could be both bots or real people connected to an authority like transportstyrelsen.
    address[] private allowedEditors;
    
    constructor() {
        superUser = msg.sender;
        allowedEditors.push(msg.sender);
    }

    // --------------- Registry functions ------------------------------

    function register(address _initialOwner, string[] memory _images, string memory _make, string memory _model, Entry.Type _type, string memory _licensePlateNr, uint8 _allowedPassengers, uint16 _year, string memory _color) external onlyAllowedEditors {
        entry.newEntry(_initialOwner, _images, _make, _model, _type, _licensePlateNr, _allowedPassengers, _year, _color);
    }

    function burn(string memory _licensePlateNr) external onlyAllowedEditors {
        entry.burnEntry(_licensePlateNr);
    }

    function see(string memory _licensePlateNr) external view returns(Entry.Item memory) {
        return entry.viewEntry(_licensePlateNr);
    }

    function editLicensePlate(string memory _currentLicensePlateNr, string memory _newLicensePlateNr) external {
        entry.editLicensePlate(_currentLicensePlateNr, _newLicensePlateNr, msg.sender);
    }

    function transfer(string memory _licensePlateNr, address _to) external {
        entry.transfer(_licensePlateNr, msg.sender, _to);
    }

    function getEntryCount() external view onlyAllowedEditors returns(uint256) {
        return entry.getCount();
    }

    //-------------- Change permissions ------------------------------------

    function addAllowedEditor(address _address) external onlyAllowedEditors returns(uint256 index) {
        for (uint256 i = 0; i < allowedEditors.length; i++){
            if (allowedEditors[i] == address(0)){
                allowedEditors[i] = _address;
                return i;
            }
        }
        allowedEditors.push(_address);
        return allowedEditors.length - 1;
    }

    function removeAllowedEditor(address _address) external onlyAllowedEditors notSuperUser(_address) {
        for (uint256 i = 0; i < allowedEditors.length; i++){
            if (allowedEditors[i] == _address){
                allowedEditors[i] = address(0);
                break;
            }
        }
    }

    function changeSuperUser(address _newAddress) external onlySuperUser {
        superUser = _newAddress;
    }

    // ---------------- modifiers -----------------------------------

    modifier onlySuperUser() {
        require(msg.sender == superUser, "You are not the super user");
        _;
    }

    modifier notSuperUser(address _address){
        require (_address != superUser, "You are not allowed to remove the super user, to remove, please change the super user to another allowedEditor and then remove the user.");
        _;
    }

    modifier onlyAllowedEditors(){
        bool isAllowed = false;
        for (uint256 i = 0; i < allowedEditors.length; i++){
            if (msg.sender == allowedEditors[i]){
                isAllowed = true;
                break;
            }
        }
        require(isAllowed == true, "You do not have permission to change or view this value.");
        _;
    }
}

