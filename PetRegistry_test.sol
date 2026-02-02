// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "remix_accounts.sol";
import "../contracts/PetRegistry.sol";

contract PetRegistryTest {
    PetRegistry petRegistry;

    string chipId = "CHIP_1";
    string name = "Zeus";
    string species = "Dog";
    uint age = 2;

    /// #sender: account-0
    function beforeAll() public {
        petRegistry = new PetRegistry();
    	petRegistry.registerPet(chipId, name, species, age);
    }

    /// #sender: account-0
    function testRegisterPet() public {
        // Test successful registration
        petRegistry.registerPet("CHIP_2", "Nala", "Cat", 3);
        (string memory fetchedName,, uint fetchedAge,,,) = petRegistry.getPet(chipId);
        Assert.equal(fetchedName, name, "Name should match");
        Assert.equal(fetchedAge, age, "Age should match");
    }

    /// #sender: account-0
    function testInputValidations() public {
        // Test empty chipId reverts
        try petRegistry.registerPet("", name, species, age) {
            Assert.ok(false, "Empty chipId should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Chip ID cannot be empty", "Should reject empty chipId");
        }

        // Test empty name reverts
        try petRegistry.registerPet("CHIP_3", "", species, age) {
            Assert.ok(false, "Empty name should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Name cannot be empty", "Should reject empty name");
        }
    }

    /// #sender: account-0
    function testUpdateName() public {
        petRegistry.updatePetName(chipId, "Ace");
        (string memory newName,, uint fetchedAge,,,) = petRegistry.getPet(chipId);
        Assert.equal(newName, "Ace", "Updated name should be Ace");
    }

    /// #sender: account-0
    function testIncrementAge() public {
        petRegistry.incrementPetAge(chipId);
        (, , uint updatedAge,,,) = petRegistry.getPet(chipId);
        Assert.equal(updatedAge, age + 1, "Age should be incremented by 1");
    }

    /// #sender: account-0
    function testRemovePet() public {
        petRegistry.removePet(chipId, "Adopted");
        (,,, bool isActive, string memory reason,) = petRegistry.getPet(chipId);
        Assert.equal(isActive, false, "Pet should be inactive");
        Assert.equal(reason, "Adopted", "Reason should be 'Adopted'");
    }

    /// #sender: account-0
    function testDuplicateRegistration() public {
        try petRegistry.registerPet(chipId, name, species, age) {
            Assert.ok(false, "Duplicate registration should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Pet with this chip ID already exists.", "Should reject duplicates");
        }
    }

    /// #sender: account-0
    function testGetPetDirectly() public {
        (
            string memory fetchedName,
            string memory fetchedSpecies,
            uint fetchedAge,
            bool isActive,
            string memory removalReason,
            address owner
        ) = petRegistry.getPet(chipId);

        // Test all fields
        Assert.equal(fetchedName, "Ace", "Name should match original");
        Assert.equal(fetchedSpecies, species, "Species should match original");
        Assert.equal(fetchedAge, 3, "Age should match original");
        Assert.equal(isActive, false, "Pet should be active initially");
        Assert.equal(removalReason, "Adopted", "Removal reason should be empty");
    }
}