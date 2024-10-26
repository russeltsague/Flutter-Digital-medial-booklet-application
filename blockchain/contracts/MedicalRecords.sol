

// contracts/MedicalRecords.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MedicalRecords {
    // Mapping to store doctor access to patient records
    mapping(address => mapping(address => bool)) public access;

    // Event to emit when access is granted
    event AccessGranted(address indexed doctor, address indexed patient);

    // Grant access to a doctor for a patient
    function grantAccess(address doctor, address patient) public {
        access[patient][doctor] = true;
        emit AccessGranted(doctor, patient);
    }

    // Check if a doctor has access to a patient's records
    function checkAccess(address patient) public view returns (bool) {
        return access[patient][msg.sender];
    }
}
