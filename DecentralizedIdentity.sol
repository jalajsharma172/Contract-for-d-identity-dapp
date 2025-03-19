// Layout of a Solidity file
// Contract :
// 1. Pragma statements/
// Import statements
// Events
// Errors
// Interfaces
// Libraries
// Contracts

// Inside each contract,
// Type declarations
// State variables
// Events
// Errors
// Modifiers
// Functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
 * @title Decentralized Identity
 * @dev This contract allows users to register their identity and upload files.
 * @notice The owner of the contract can approve or reject the uploaded files.
 *@dev The owner of the contract can approve or reject the uploaded files.
 */

contract DecentralizedIdentity {
    address public immutable i_owner;
    /* CTL+SHIFT+A */
    /*@dev Counting Number Of Pending User's who are not Approved yet */
    uint private s_count = 0; 
    uint public id = 1;

    enum State {
        Pending,
        Approve,
        Reject
    }

    mapping(address => User) private userinfo;
    mapping(uint => mapping(address => User)) private userfiles;
    mapping(address => uint) private getid;

    // Array to store all users who have uploaded files
    address[] private allUsers;
    struct User {
        string name;
        uint age;
        string hashcode;
        State status;
    }
    constructor() {
        i_owner = msg.sender;
    }

    event UserRegistered(address indexed user);
    event FileUploaded(address indexed user, uint indexed id, string hashcode);
    event StatusUpdated(address indexed user, uint indexed id, State status);
    error UnAuthoriizedAccess(address user);

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Only owner can call this function");
        _;
    }

    modifier RegisterOnce(address user) {
        require(
            bytes(userinfo[user].name).length == 0,
            "User already registered"
        );
        _;
    }

    modifier onlyUser(address user) {
        require(
            bytes(userinfo[user].hashcode).length != 0,
            "User not registered"
        );
        _;
    }

    function registerUser(
        string memory _name,
        uint _age
    ) external RegisterOnce(msg.sender) {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_age > 0, "Age cannot be Zero");
        User memory userdata = User(_name, _age, "_", State.Pending);
        userinfo[msg.sender] = userdata;
        emit UserRegistered(msg.sender);
    }
    /**You can Push Your Files To Send To Admin Or You Can Also Edit Hashcode for Admin,before  */
    function pushFiles(
        string memory _hashcode
    ) external onlyUser(msg.sender) returns (uint _id) {
        // Add user to the list if not already present
        require(bytes(_hashcode).length > 0, "Hashcode cannot be empty");
        if (!isUserInList(msg.sender)) {
            allUsers.push(msg.sender);
            id++;
        } else {
            uint temp_id = getid[msg.sender];
            
            User memory selected_user = userfiles[temp_id][msg.sender];
            // require(userdata.status == State.Approve, "User is already in the list");
            if (selected_user.status == State.Approve) {
                selected_user.status = State.Pending;
                selected_user.hashcode = _hashcode;
                allUsers.push(msg.sender);
                s_count++;
            }
        }
        User memory userdata = userinfo[msg.sender];
        userdata.hashcode = _hashcode;
        userfiles[id][msg.sender] = userdata;
        s_count++; //Counting Number of Pending Users for Admin

        getid[msg.sender] = id;
        emit FileUploaded(msg.sender, id, _hashcode);
        return (id - 1);
    }

    function giveMyDetails()
        external
        view
        returns (
            string memory hashData,
            State status,
            string memory name,
            uint age
        )
    {
        //use msg.sender

        uint temp_id = getid[msg.sender];
        User memory details = userfiles[temp_id][msg.sender];

        return (details.hashcode, details.status, details.name, details.age);
    }

    function approveUser(address _user) external onlyOwner {
        uint _id = getid[msg.sender];
        User storage userdata = userfiles[_id][_user];
        require(
            bytes(userdata.hashcode).length != 0,
            "User or file does not exist"
        );
        userdata.status = State.Approve;
        s_count--;
        emit StatusUpdated(_user, _id, userdata.status);
    }

    // Helper function to check if a user is already in the list
    function isUserInList(address user) private view returns (bool) {
        for (uint i = 0; i < allUsers.length; i++) {
            if (allUsers[i] == user) {
                return true;
            }
        }
        return false;
    }
    function getUserID() external view returns (uint) {
        return getid[msg.sender];
    }

    // Function to get all users[Address,HASHCODE] in the Pending state
    // Function to get all users [Address, HASHCODE] in the Pending state
    function getPendingUsers()
        external
        view
        onlyOwner
        returns (address[] memory, string[] memory)
    {
        // First, count the number of users in the Pending state
        uint count = s_count;
        for (uint i = 0; i < allUsers.length; i++) {
            if (userinfo[allUsers[i]].status == State.Pending) {
                count++;
            }
        }

        // Initialize arrays with the correct size
        address[] memory pendingUsers = new address[](count);
        string[] memory pendingHashcodes = new string[](count);

        // Populate the arrays
        uint index = 0;
        for (uint i = 0; i < allUsers.length; i++) {
            address userAddress = allUsers[i];
            User memory userdata = userinfo[userAddress];
            string memory userhashcode = userdata.hashcode;
            if (userdata.status == State.Pending) {
                pendingUsers[index] = userAddress;
                pendingHashcodes[index] = userhashcode;
                index++;
            }
        }

        return (pendingUsers, pendingHashcodes);
    }
}
