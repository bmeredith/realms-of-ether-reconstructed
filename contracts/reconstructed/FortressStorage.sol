pragma solidity 0.4.18;

import "./SafeMath.sol";

/// @title FortressStorage for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Persistent on-chain storage contract for Fortresses in Realms of Ether.
/// Stores their resources (gold, wood, stone), building attributes (level, timeout),   
/// and attributes for each fortress, keyed by a bytes32 hash identifier.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
contract FortressStorage {
    using SafeMath for uint256;

    address public owner; // STORAGE[0x0] bytes 0 to 19
    uint256 public genesisTime; // STORAGE[0x1]
    uint256 public initalFortressCount; // STORAGE[0x2] 0x5d694a72
    mapping(address => bytes32[]) public ownerFortresses; // STORAGE[0x3]
    mapping(address => uint256) public ownerFortressesLength; // STORAGE[0x4]
    mapping(address => uint256) public ownerFortressesCount; // STORAGE[0x5]
    mapping(bytes32 => uint256) public fortressOwnerIndex; // STORAGE[0x6]
    bytes32[] public fortressHashes; // STORAGE[0x7]
    mapping(bytes32 => bool) internal exists; // STORAGE[0x8]
    mapping(bytes32 => bytes16) internal names; // STORAGE[0x9]
    mapping(bytes32 => address) internal fortressOwner; // STORAGE[0xa]
    mapping(bytes32 => int256) internal x; // STORAGE[0xb]
    mapping(bytes32 => int256) internal y; // STORAGE[0xc]
    mapping(bytes32 => uint256) internal gold; // STORAGE[0xd]
    mapping(bytes32 => uint256) internal wood; // STORAGE[0xe]
    mapping(bytes32 => uint256) internal stone; // STORAGE[0xf]
    mapping(bytes32 => uint256) internal troups; // STORAGE[0x10]
    // STORAGE[0x11] - unknown, may be unused or unreferenced
    mapping(bytes32 => uint256) internal buildingLevel; // STORAGE[0x12]
    mapping(bytes32 => uint256) internal buildingTimeout; // STORAGE[0x13]

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function FortressStorage() public {
        owner = msg.sender;
        initalFortressCount = 1000;
    }

    function _getFortressesAvailable() 
        private 
        returns (uint256)
    { 
        uint256 fortressesRemaining = _fortressesRemaining();
        return fortressesRemaining - fortressHashes.length;
    }

    function getFortressCount() 
        public 
        returns (uint256)
    { 
        return fortressHashes.length;
    }

    function totalSupply() 
        public 
        returns (uint256)
    { 
        return _fortressesRemaining();
    }

    function setWins(
        bytes32 _fortressHash, 
        uint256 _wins
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        troups[_fortressHash] = _wins;
    }

    function getY(bytes32 _fortressHash) 
        public 
        returns (int256)
    { 
        require(exists[_fortressHash]);
        return y[_fortressHash];
    }

    function getBuildingLevel(
        bytes32 _fortressHash, 
        bytes32 _buildingHash
    ) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return buildingLevel[keccak256(_fortressHash, _buildingHash)];
    }

    function createFortress(
        bytes32 _fortressHash, 
        address _user
    ) 
        public 
    { 
        require(msg.sender == owner);
        uint256 v0 = _getFortressesAvailable();
        require(v0 > fortressHashes.length);
        require(!exists[_fortressHash]);
        
        fortressHashes.push(_fortressHash);
        exists[_fortressHash] = true;
        fortressOwner[_fortressHash] = _user;
        ownerFortresses[_user].push(_fortressHash);

        fortressOwnerIndex[_fortressHash] = ownerFortressesLength[_user];
        ownerFortressesLength[_user] = ownerFortressesLength[_user].add(1);
        ownerFortressesCount[_user] = ownerFortressesCount[_user].add(1);
    }

    function setTroups(
        bytes32 _fortressHash, 
        bytes32 _troupHash, 
        uint256 _amount
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        troups[keccak256(_fortressHash, _troupHash)] = _amount;
    }

    function getFortressesAvailable()
        public 
        returns (uint256)
    { 
        return _getFortressesAvailable();
    }

    function getName(bytes32 _fortressHash) 
        public 
        returns (bytes16)
    { 
        require(exists[_fortressHash]);
        return names[_fortressHash];
    }

    function setOwner(
        bytes32 _fortressHash, 
        address _newOwner
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        assert(fortressOwnerIndex[_fortressHash] < ownerFortresses[fortressOwner[_fortressHash]].length);
        ownerFortresses[fortressOwner[_fortressHash]][fortressOwnerIndex[_fortressHash]] = bytes32(0);
        ownerFortressesCount[fortressOwner[_fortressHash]] = ownerFortressesCount[fortressOwner[_fortressHash]].sub(1);
        fortressOwner[_fortressHash] = _newOwner;

        ownerFortresses[_newOwner].push(_fortressHash);

        fortressOwnerIndex[_fortressHash] = ownerFortressesLength[_newOwner];
        ownerFortressesLength[_newOwner] = ownerFortressesLength[_newOwner].add(1);
        ownerFortressesCount[_newOwner] = ownerFortressesCount[_newOwner].add(1);
    }

    // 0x5d694a72 - this is not the real function name
    // it was mined to get a collision match of the actual function name for now
    function genesis30456072818() 
        public 
        returns (uint256)
    { 
        return initalFortressCount;
    }

    function setX(
        bytes32 _fortressHash, 
        int256 _x
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        x[_fortressHash] = _x;
    }

    function getTroups(
        bytes32 _fortressHash, 
        bytes32 _troupHash
    ) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return troups[keccak256(_fortressHash, _troupHash)];
    }

    function setStone(
        bytes32 _fortressHash, 
        uint256 _amount
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        stone[_fortressHash] = _amount;
    }

    function balanceOf(address _owner) 
        public 
        returns (uint256) 
    {
        return ownerFortressesCount[_owner];
    }

    function setGold(
        bytes32 _fortressHash, 
        uint256 _amount
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        gold[_fortressHash] = _amount;
    }

    function getHashFromIndex(
        address _user, 
        uint256 _index
    ) 
        public 
        returns (bytes32)
    { 
        assert(_index < ownerFortresses[_user].length);
        return ownerFortresses[_user][_index];
    }

    function setBuildingLevel(
        bytes32 _fortressHash, 
        bytes32 _buildingHash, 
        uint256 _level
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        buildingLevel[keccak256(_fortressHash, _buildingHash)] = _level;
    }

    function startMinting() 
        public 
    { 
        require(msg.sender == owner);
        require(genesisTime == 0);
        genesisTime = block.timestamp;
    }

    function setWood(
        bytes32 _fortressHash, 
        uint256 _amount
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        wood[_fortressHash] = _amount;
    }

    function getBuildingTimeout(
        bytes32 _fortressHash, 
        bytes32 _buildingHash
    )
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return buildingTimeout[keccak256(_fortressHash, _buildingHash)];
    }

    function getWins(bytes32 _fortressHash) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return troups[_fortressHash];
    }

    function setY(
        bytes32 _fortressHash, 
        int256 _y
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        y[_fortressHash] = _y;
    }

    function setBuildingTimeout(
        bytes32 _fortressHash, 
        bytes32 _buildingHash, 
        uint256 _timeout
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        buildingTimeout[keccak256(_fortressHash, _buildingHash)] = _timeout;
    }

    function getX(bytes32 _fortressHash) 
        public 
        returns (int256)
    { 
        require(exists[_fortressHash]);
        return x[_fortressHash];
    }

    function fortressExists(bytes32 _fortressHash) 
        public 
        returns (bool)
    { 
        return exists[_fortressHash];
    }

    function getOwner(bytes32 _fortressHash) 
        public 
        returns (address)
    { 
        require(exists[_fortressHash]);
        return fortressOwner[_fortressHash];
    }

    function getWood(bytes32 _fortressHash) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return wood[_fortressHash];
    }

    function getStone(bytes32 _fortressHash) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return stone[_fortressHash];
    }

    function getGold(bytes32 _fortressHash) 
        public 
        returns (uint256)
    { 
        require(exists[_fortressHash]);
        return gold[_fortressHash];
    }

    function transferOwnership(address newOwner) 
        public 
    { 
        require(msg.sender == owner);
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getIndexLength(address _user) 
        public 
        returns (uint256)
    { 
        return ownerFortressesLength[_user];
    }

    function setName(
        bytes32 _fortressHash, 
        bytes16 _name
    ) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_fortressHash]);
        
        names[_fortressHash] = _name;
    }

    function _fortressesRemaining() 
        private 
        returns (uint256)
    { 
        if (genesisTime != 0) {
            return initalFortressCount.add((block.timestamp - genesisTime) / 900);
        } else {
            return initalFortressCount;
        }
    }

    function() public payable {
        revert();
    }
}