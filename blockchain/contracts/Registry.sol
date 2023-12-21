//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Registry {
    //the superUser
    address private superUser;

    //Could be both bots or real people connected to an authority like transportstyrelsen.
    address[] private allowedEditors;

    //Mapping of licensePlateNumber to Entry struct
    mapping(string => Entry) public registry;
    
    struct Entry {
        string[] images;
        string make;
        string model;
        string licensePlateNr;
        uint8 allowedPassengers;
        uint16 year;
        string color;
        address[] prevOwners;
        address currentOwner;
    }

    constructor(){
        superUser = msg.sender;
        allowedEditors[0] = msg.sender;
    }


    // --------------- Registry functions ------------------------------

    //adds a new item to the registry
    function register() external onlyAllowedEditors {

    }

    //removes an item from the registry
    function burnRegister() external onlyAllowedEditors {

    }

    //function transferOwnerShip() external onlyOwner {

    //}





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






    // ------------- Helpers --------------------------------------------------

    




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
        require(isAllowed == true, "You do not have permission to change this value.");
        _;
    }


}

