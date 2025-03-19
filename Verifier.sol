// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DecentralizedIdentity} from "./DecentralizedIdentity.sol"; // Import the main contract

contract Verifier {
    address public immutable i_refugeeAdmin; // Address of the Refugee Admin
    DecentralizedIdentity public decentralizedIdentity; // Reference to the main contract

    mapping(address => bool) public verifiers; // Tracks registered verifiers

    modifier onlyRefugeeAdmin() {
        require(msg.sender == i_refugeeAdmin, "Only Refugee Admin can call this function");
        _;
    }

    modifier onlyVerifier() {
        require(verifiers[msg.sender], "Only registered verifiers can call this function");
        _;
    }

    constructor(address _decentralizedIdentityAddress) {
        i_refugeeAdmin = msg.sender; // Set the deployer as the Refugee Admin
        decentralizedIdentity = DecentralizedIdentity(_decentralizedIdentityAddress); // Link to the main contract
    }

    // Function to register a verifier (only Refugee Admin can call this)
    function registerVerifier(address _verifier) public onlyRefugeeAdmin {
        require(!verifiers[_verifier], "Verifier already registered");
        verifiers[_verifier] = true;
    }

    // Function to verify a user's age (only registered verifiers can call this)
    function verifyUserAge(address _user, uint _expectedAge) public onlyVerifier returns (bool) {
        (, uint age, , ) = decentralizedIdentity.getUserDetails(_user); // Get user details from the main contract
        // return age == _expectedAge; // Return true if the age matches
    }
}
