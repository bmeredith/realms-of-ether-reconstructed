pragma solidity 0.4.18;

/// @title TroupStorage for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Persistent on-chain storage contract for "troup" game units in Realms of Ether.
/// Stores stats (life, strength, intelligence, dexterity) and resources (gold, wood, stone)
/// for each troup, keyed by a bytes32 hash identifier.
///
/// @dev This contract is an on-chain storage contract that manages 
/// all persistent data for "troups" in Realms of Ether.
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
contract TroupStorage {
    address public owner;
    bytes32[] internal troupHashes;

    // tracks whether a given hash has been registered via createTroup()
    mapping(bytes32 => bool) internal exists;
    mapping(bytes32 => bytes16) internal names;

    // core combat stats
    mapping(bytes32 => uint256) internal life;
    mapping(bytes32 => uint256) internal strength;
    mapping(bytes32 => uint256) internal intelligence;
    mapping(bytes32 => uint256) internal dexterity;

    // held resources
    mapping(bytes32 => uint256) internal gold;
    mapping(bytes32 => uint256) internal wood;
    mapping(bytes32 => uint256) internal stone;
    
    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function TroupStorage() public {
        owner = msg.sender;
    }

    function() public payable {
        revert();
    }

    function setStrength(bytes32 _troupHash, uint256 _amount) 
        public 
    {
        require(msg.sender == owner);
        require(exists[_troupHash]);
        strength[_troupHash] = _amount;
    }

    function setIntelligence(bytes32 _troupHash, uint256 _amount) 
        public 
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        intelligence[_troupHash] = _amount;
    }

    function getName(bytes32 _troupHash) 
        public
        view
        returns (bytes16)
    {
        require(exists[_troupHash]);
        return names[_troupHash];
    }

    function getStrength(bytes32 _troupHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return strength[_troupHash];
    }

    function getHash(uint256 _nonce) 
        public
        view
        returns (bytes32)
    {
        return troupHashes[_nonce];
    }

    function setStone(bytes32 _troupHash, uint256 _amount)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        stone[_troupHash] = _amount;
    }

    function setGold(bytes32 _troupHash, uint256 _amount)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        gold[_troupHash] = _amount;
    }

    function setDexterity(bytes32 _troupHash, uint256 _amount)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        dexterity[_troupHash] = _amount;
    }

    function getIntelligence(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return intelligence[_troupHash];
    }

    /// @notice Registers a new troup hash. Must be called before any stats can be read or written.
    /// @dev Reverts if the hash is already registered.
    function createTroup(bytes32 _troupHash)
        public
    { 
        require(msg.sender == owner);
        require(!exists[_troupHash]);

        troupHashes.push(_troupHash);
        exists[_troupHash] = true;
    }

    function getLife(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return life[_troupHash];
    }

    function getDexterity(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return dexterity[_troupHash];
    }

    function setWood(bytes32 _troupHash, uint256 _amount)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        wood[_troupHash] = _amount;
    }

    function setLife(bytes32 _troupHash, uint256 _amount)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);
        life[_troupHash] = _amount;
    }

    function getWood(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return wood[_troupHash];
    }

    function getIndexLength()
        public
        view
        returns (uint256)
    { 
        return troupHashes.length;
    }

    function getStone(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return stone[_troupHash];
    }

    function getGold(bytes32 _troupHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_troupHash]);
        return gold[_troupHash];
    }

    function transferOwnership(address newOwner) 
        public
    { 
        require(msg.sender == owner);
        require(bool(newOwner != address(0x0)));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setName(bytes32 _troupHash, bytes16 _name)
        public
    { 
        require(msg.sender == owner);
        require(exists[_troupHash]);

        names[_troupHash] = _name;
    }
}