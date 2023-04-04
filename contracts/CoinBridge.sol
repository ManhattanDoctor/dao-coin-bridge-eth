// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

contract CoinBridge is Ownable {
    // --------------------------------------------------------------------------
    //
    //  Structs
    //
    // --------------------------------------------------------------------------

    struct OperationDto {
        string name;
        string coinUid;
        string objectUid;
        address target;
        uint256 amount;
    }

    struct ValidatorDto {
        address validator;
        uint256 total;
    }

    // --------------------------------------------------------------------------
    //
    //  Events
    //
    // --------------------------------------------------------------------------

    event Operation(OperationDto data);
    event ValidatorAdded(ValidatorDto data);
    event ValidatorRemoved(ValidatorDto data);

    // --------------------------------------------------------------------------
    //
    //  Properties
    //
    // --------------------------------------------------------------------------

    string public name;
    uint8 public decimals;
    uint256 public depositMin;
    uint256 public withdrawalMin;

    mapping(address => bool) public validators;
    uint8 public validatorsTotal;

    // --------------------------------------------------------------------------
    //
    //  Constructor
    //
    // --------------------------------------------------------------------------

    constructor(string memory _name, uint8 _decimals, uint256 _depositMin, uint256 _withdrawalMin) {
        name = _name;
        decimals = _decimals;
        depositMin = _depositMin;
        withdrawalMin = _withdrawalMin;

        validatorsTotal = 0;
        validatorAdd(owner());
    }

    // --------------------------------------------------------------------------
    //
    //  Private Methods
    //
    // --------------------------------------------------------------------------

    function message(string memory objectUid, string memory coinUid, address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(objectUid, coinUid, to, amount));
    }

    // --------------------------------------------------------------------------
    //
    //  Public Methods
    //
    // --------------------------------------------------------------------------

    function deposit(string memory objectUid, string memory coinUid) public payable {
        address sender = _msgSender();
        uint256 amount = msg.value;
        require(amount >= depositMin, 'Deposit must be equal or granter than depositMin value');
        emit Operation(OperationDto({name: 'Deposited', objectUid: objectUid, coinUid: coinUid, target: sender, amount: amount}));
    }

    function withdraw(string memory objectUid, string memory coinUid, address to, uint256 amount, bytes[] memory signatures) public {
        require(signatures.length > 0, 'Signatures must be not empty');
        bytes32 hashedMessage = ECDSA.toEthSignedMessageHash(message(objectUid, coinUid, to, amount));

        uint256 signers = 0;
        for (uint i = 0; i < signatures.length; i++) {
            bytes memory signature = signatures[i];
            address signer = ECDSA.recover(hashedMessage, signature);
            if (validatorHas(signer)) {
                signers++;
            }
        }

        require(signers > 0, 'Signed validators signature must be more than zero');

        Address.sendValue(payable(to), amount);
        emit Operation(OperationDto({name: 'Withdrew', objectUid: objectUid, coinUid: coinUid, target: to, amount: amount}));
    }

    // --------------------------------------------------------------------------
    //
    //  Help Methods
    //
    // --------------------------------------------------------------------------

    function validatorHas(address validator) public view returns (bool) {
        require(validator != address(0), 'Validator must be not the zero address');
        return validators[validator];
    }

    function validatorAdd(address validator) public onlyOwner {
        require(validator != address(0), 'Validator must be not the zero address');
        validators[validator] = true;
        validatorsTotal += 1;
        emit ValidatorAdded(ValidatorDto({validator: validator, total: validatorsTotal}));
    }

    function validatorRemove(address validator) public onlyOwner {
        require(validator != address(0), 'Validator must be not the zero address');
        validators[validator] = false;
        validatorsTotal -= 1;
        emit ValidatorRemoved(ValidatorDto({validator: validator, total: validatorsTotal}));
    }

    function depositMinSet(uint256 value) public onlyOwner {
        require(value > 0, 'Minimal deposit must be granter than zero');
        depositMin = value;
    }

    function withdrawalMinSet(uint256 value) public onlyOwner {
        require(value > 0, string.concat('Minimal withdrawal must be granter than zero'));
        withdrawalMin = value;
    }

    // --------------------------------------------------------------------------
    //
    //  Public Properties
    //
    // --------------------------------------------------------------------------

    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}

