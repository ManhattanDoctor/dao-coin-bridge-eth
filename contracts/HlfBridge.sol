// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';

contract HlfBridge is Ownable {
    // --------------------------------------------------------------------------
    //
    //  Structs
    //
    // --------------------------------------------------------------------------

    struct Deposit {
        string objectUid;
        string coinUid;
        string name;
        uint256 decimals;
        uint256 amount;
        address from;
        uint256 date;
    }

    struct Withdrawal {
        string objectUid;
        string coinUid;
        uint256 name;
        uint256 decimals;
        uint256 amount;
        address to;
        uint256 date;
    }

    // --------------------------------------------------------------------------
    //
    //  Events
    //
    // --------------------------------------------------------------------------

    event Withdrew(Withdrawal data);
    event Deposited(Deposit data);

    // --------------------------------------------------------------------------
    //
    //  Properties
    //
    // --------------------------------------------------------------------------

    string public name;
    uint256 public decimals;
    uint256 public depositMin;
    uint256 public withdrawalMin;

    mapping(address => Deposit[]) public deposits;
    mapping(address => Withdrawal[]) public withdrawals;

    // --------------------------------------------------------------------------
    //
    //  Constructor
    //
    // --------------------------------------------------------------------------

    constructor(string memory _name, uint256 _decimals, uint256 _depositMin, uint256 _withdrawalMin) {
        name = _name;
        decimals = _decimals;
        depositMin = _depositMin;
        withdrawalMin = _withdrawalMin;
    }

    // --------------------------------------------------------------------------
    //
    //  Public Methods
    //
    // --------------------------------------------------------------------------

    function deposit(string memory objectUid, string memory coinUid) public payable {
        address from = msg.sender;
        uint256 amount = msg.value;
        require(amount >= depositMin, string.concat('Deposit must be equal or granter than ', Strings.toString(depositMin)));

        Deposit memory item = Deposit({
            name: name,
            decimals: decimals,
            objectUid: objectUid,
            coinUid: coinUid,
            from: from,
            amount: amount,
            date: block.timestamp
        });

        deposits[from].push(item);
        emit Deposited(item);
    }

    /*
    function hash(string memory objectUid, string memory coinUid, address to, uint256 amount) private pure returns (bytes32) {
        bytes memory message = abi.encode(objectUid, coinUid, to, amount);
        return keccak256(message);
    }
    function verify(string memory objectUid, string memory coinUid, address to, uint256 amount) public pure returns (bytes32) {
        bytes32 hashMessage = hash(objectUid, coinUid, to, amount);
        return hashMessage;
    }
    */

    function message(string memory objectUid, string memory coinUid, address to, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(objectUid, coinUid, to, amount));
    }

    function verify(string memory objectUid, string memory coinUid, address to, uint256 amount, bytes memory signature) public pure returns (address) {
        bytes32 hashedMessage = ECDSA.toEthSignedMessageHash(message(objectUid, coinUid, to, amount));
        address signer = ECDSA.recover(hashedMessage, signature);
        return signer;
    }

    // --------------------------------------------------------------------------
    //
    //  Owner Methods
    //
    // --------------------------------------------------------------------------

    function depositMinSet(uint256 value) public onlyOwner {
        require(value > 0, string.concat('Minimal deposit must be granter than zero'));
        depositMin = value;
    }

    function withdrawalMinSet(uint256 value) public onlyOwner {
        require(value > 0, string.concat('Minimal withdrawal must be granter than zero'));
        withdrawalMin = value;
    }

    // TODO: remove from production
    function refund() public onlyOwner {
        address payable to = payable(this.owner());
        Address.sendValue(to, balanceGet());
    }

    // --------------------------------------------------------------------------
    //
    //  Public Properties
    //
    // --------------------------------------------------------------------------

    function balanceGet() public view returns (uint256) {
        return address(this).balance;
    }

    function depositsGet(address from) public view returns (Deposit[] memory) {
        return deposits[from];
    }

    function withdrawalsGet(address to) public view returns (Withdrawal[] memory) {
        return withdrawals[to];
    }
}


/*
function hash(string memory objectUid, string memory coinUid, address to, uint256 amount) private pure returns (bytes32) {
    bytes memory message = abi.encode(objectUid, coinUid, to, amount);
    return keccak256(message);
}
function verify(string memory objectUid, string memory coinUid, address to, uint256 amount) public pure returns (bytes32) {
    bytes32 hashMessage = hash(objectUid, coinUid, to, amount);
    return hashMessage;
}
*/
