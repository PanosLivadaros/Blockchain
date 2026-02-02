// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PetRegistry {
    // Events
    event PetRegistered(string indexed chipId, address owner);
    event PetNameUpdated(string indexed chipId, string newName);
    event PetAgeIncremented(string indexed chipId, uint newAge);
    event PetRemoved(string indexed chipId, string reason);

    // Pet information
    struct Pet {
        string name;
        string species;
        uint age;
        bool isActive;
        string removalReason;
        address owner;
    }

    // Mapping from chip ID to Pet
    mapping(string => Pet) private pets;

    // Ensure only the pet's owner can modify its data
    modifier onlyOwner(string memory chipId) {
        require(pets[chipId].owner == msg.sender, "You are not the owner of this pet.");
        _;
    }

    // Register new pet
    function registerPet(string memory chipId, string memory name, string memory species, uint age) public {
        require(bytes(chipId).length > 0, "Chip ID cannot be empty");
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(species).length > 0, "Species cannot be empty");
        require(pets[chipId].owner == address(0), "Pet with this chip ID already exists.");
        
        pets[chipId] = Pet(name, species, age, true, "", msg.sender);
        emit PetRegistered(chipId, msg.sender);
    }

    // Update pet name
    function updatePetName(string memory chipId, string memory newName) public onlyOwner(chipId) {
        require(pets[chipId].isActive, "Pet is no longer active.");
        pets[chipId].name = newName;
        emit PetNameUpdated(chipId, newName);
    }

    // Increment pet age by 1
    function incrementPetAge(string memory chipId) public onlyOwner(chipId) {
        require(pets[chipId].isActive, "Pet is no longer active.");
        pets[chipId].age += 1;
        emit PetAgeIncremented(chipId, pets[chipId].age);
    }

    // Deactivate pet with removal reason
    function removePet(string memory chipId, string memory reason) public onlyOwner(chipId) {
        require(pets[chipId].isActive, "Pet is already inactive.");
        pets[chipId].isActive = false;
        pets[chipId].removalReason = reason;
        emit PetRemoved(chipId, reason);
    }

    // Retrieve pet details by chip ID
    function getPet(string memory chipId) public view returns (
        string memory name,
        string memory species,
        uint age,
        bool isActive,
        string memory removalReason,
        address owner
    ) {
        Pet memory pet = pets[chipId];
        require(pet.owner != address(0), "Pet not found.");
        return (
            pet.name,
            pet.species,
            pet.age,
            pet.isActive,
            pet.removalReason,
            pet.owner
        );
    }
}
