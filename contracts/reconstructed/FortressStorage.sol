pragma solidity 0.4.18;

/// @title FortressStorage for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Persistent on-chain storage contract for Fortresses in Realms of Ether.
/// Stores their resources (gold, wood, stone), building attributes (level, timeout),   
/// and attributes for each fortress, keyed by a bytes32 hash identifier.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract FortressStorage {
    using SafeMath for uint256;

    address public owner;
    uint256 public genesisTime;
    uint256 public initalFortressCount;
    mapping(address => bytes32[]) public ownerFortresses;
    mapping(address => uint256) public ownerFortressesLength;
    mapping(address => uint256) public ownerFortressesCount;
    mapping(bytes32 => uint256) public fortressOwnerIndex;
    bytes32[] public fortressHashes;
    mapping(bytes32 => bool) public fortressExists;
    mapping(bytes32 => bytes16) internal names;
    mapping(bytes32 => address) internal fortressOwner;
    mapping(bytes32 => int256) internal x;
    mapping(bytes32 => int256) internal y;
    mapping(bytes32 => uint256) internal gold;
    mapping(bytes32 => uint256) internal wood;
    mapping(bytes32 => uint256) internal stone;
    mapping(bytes32 => uint256) internal troups;
    mapping(bytes32 => uint256) internal unused;
    mapping(bytes32 => uint256) internal buildingLevel;
    mapping(bytes32 => uint256) internal buildingTimeout;

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function FortressStorage() public {
        owner = msg.sender;
        initalFortressCount = 1000;
    }

    function getFortressCount()
        public
        view
        returns (uint256)
    {
        return fortressHashes.length;
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        if (genesisTime == 0) {
            return initalFortressCount;
        }

        uint256 timeSinceGenesis = now - genesisTime;
        return initalFortressCount.add(timeSinceGenesis.div(900));
    }

    function setWins(
        bytes32 _fortressHash,
        uint256 _wins
    )
        public
    {
        require(msg.sender == owner);
        require(fortressExists[_fortressHash]);
        troups[_fortressHash] = _wins;
    }

    function getY(bytes32 _fortressHash)
        public
        view
        returns (int256)
    {
        require(fortressExists[_fortressHash]);
        return y[_fortressHash];
    }

    function getBuildingLevel(
        bytes32 _fortressHash,
        bytes32 _buildingHash
    )
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _buildingHash);
        return buildingLevel[hash];
    }

    function createFortress(
        bytes32 _fortressHash,
        address _user
    )
        public
    {
        require(msg.sender == owner);
        require(getFortressesAvailable() > getFortressCount());
        require(!fortressExists[_fortressHash]);

        fortressHashes.push(_fortressHash);
        fortressExists[_fortressHash] = true;
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
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _troupHash);
        troups[hash] = _amount;
    }

    function getFortressesAvailable()
        public
        view
        returns (uint256)
    {
        return totalSupply().sub(getFortressCount());
    }

    function getName(bytes32 _fortressHash)
        public
        view
        returns (bytes16)
    {
        require(fortressExists[_fortressHash]);
        return names[_fortressHash];
    }

    function setOwner(
        bytes32 _fortressHash,
        address _newOwner
    )
        public
    {
        require(msg.sender == owner);
        require(fortressExists[_fortressHash]);

        ownerFortresses[fortressOwner[_fortressHash]][fortressOwnerIndex[_fortressHash]] = bytes32(0);
        ownerFortressesCount[fortressOwner[_fortressHash]] = ownerFortressesCount[fortressOwner[_fortressHash]].sub(1);
        fortressOwner[_fortressHash] = _newOwner;

        ownerFortresses[_newOwner].push(_fortressHash);

        fortressOwnerIndex[_fortressHash] = ownerFortressesLength[_newOwner];
        ownerFortressesLength[_newOwner] = ownerFortressesLength[_newOwner].add(1);
        ownerFortressesCount[_newOwner] = ownerFortressesCount[_newOwner].add(1);
    }

    function setX(
        bytes32 _fortressHash,
        int256 _x
    )
        public
    {
        require(msg.sender == owner);
        require(fortressExists[_fortressHash]);
        x[_fortressHash] = _x;
    }

    function getTroups(
        bytes32 _fortressHash,
        bytes32 _troupHash
    )
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _troupHash);
        return troups[hash];
    }

    function setStone(
        bytes32 _fortressHash,
        uint256 _amount
    )
        public
    {
        require(msg.sender == owner);
        require(fortressExists[_fortressHash]);
        stone[_fortressHash] = _amount;
    }

    function balanceOf(address _owner)
        public
        view
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
        require(fortressExists[_fortressHash]);
        gold[_fortressHash] = _amount;
    }

    function getHashFromIndex(
        address _user,
        uint256 _index
    )
        public
        view
        returns (bytes32)
    {
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
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _buildingHash);
        buildingLevel[hash] = _level;
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
        require(fortressExists[_fortressHash]);
        wood[_fortressHash] = _amount;
    }

    function getBuildingTimeout(
        bytes32 _fortressHash,
        bytes32 _buildingHash
    )
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _buildingHash);
        return buildingTimeout[hash];
    }

    function getWins(bytes32 _fortressHash)
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        return troups[_fortressHash];
    }

    function setY(
        bytes32 _fortressHash,
        int256 _y
    )
        public
    {
        require(msg.sender == owner);
        require(fortressExists[_fortressHash]);
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
        require(fortressExists[_fortressHash]);
        bytes32 hash = keccak256(_fortressHash, _buildingHash);
        buildingTimeout[hash] = _timeout;
    }

    function getX(bytes32 _fortressHash)
        public
        view
        returns (int256)
    {
        require(fortressExists[_fortressHash]);
        return x[_fortressHash];
    }

    function getOwner(bytes32 _fortressHash)
        public
        view
        returns (address)
    {
        require(fortressExists[_fortressHash]);
        return fortressOwner[_fortressHash];
    }

    function getWood(bytes32 _fortressHash)
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        return wood[_fortressHash];
    }

    function getStone(bytes32 _fortressHash)
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
        return stone[_fortressHash];
    }

    function getGold(bytes32 _fortressHash)
        public
        view
        returns (uint256)
    {
        require(fortressExists[_fortressHash]);
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
        view
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
        require(fortressExists[_fortressHash]);
        names[_fortressHash] = _name;
    }

    function() public payable {
        revert();
    }
}