pragma solidity 0.4.18;

/// @title BuildingStorage for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Persistent on-chain storage contract for Buildings in Realms of Ether.
/// Stores build costs (gold, wood, stone) and action attributes for each building,
/// keyed by a bytes32 hash identifier. Buildings can either be mined for resources
/// or used to recruit troups, each on a timed interval.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
contract BuildingStorage {
    address public owner;
    bytes32[] internal buildingHashes;
    
    // tracks whether a given hash has been registered via createBuilding()
    mapping(bytes32 => bool) internal exists;

    // name of the building
    mapping(bytes32 => bytes16) internal names;

    // type of action the building supports (1=mine, 2=recruit)
    mapping(bytes32 => uint256) internal action;
    
    // base resource yield per level when mining
    mapping(bytes32 => uint256) internal actionRate;

    // if action=1 (mine): a hash identifying the resource type (gold, wood, or stone)
    // if action=2 (recruit): a hash identifying the troup to recruit
    mapping(bytes32 => bytes32) internal actionValue;

    // cooldown (in hours) between mining or recruiting actions
    mapping(bytes32 => uint256) internal actionTimeout;
    
    // resources required to construct the building
    mapping(bytes32 => uint256) internal gold;
    mapping(bytes32 => uint256) internal wood;
    mapping(bytes32 => uint256) internal stone;

    // events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function BuildingStorage() public {
        owner = msg.sender;
    }

    function() public payable { 
        revert();
    }

    function getActionTimeout(bytes32 _buildingHash)
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return actionTimeout[_buildingHash];
    }

    function createBuilding(bytes32 _buildingHash) 
        public
    { 
        require(msg.sender == owner);
        require(!exists[_buildingHash]);
        
        buildingHashes.push(_buildingHash);
        exists[_buildingHash] = true;
    }

    function setActionValue(bytes32 _buildingHash, bytes32 _actionValue) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        actionValue[_buildingHash] = _actionValue;
    }

    function setActionRate(bytes32 _buildingHash, uint256 _actionRate) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        actionRate[_buildingHash] = _actionRate;
    }

    function setAction(bytes32 _buildingHash, uint256 _action) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        action[_buildingHash] = _action;
    }

    function getActionRate(bytes32 _buildingHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return actionRate[_buildingHash];
    }

    function getName(bytes32 _buildingHash) 
        public
        view
        returns (bytes16)
    { 
        require(exists[_buildingHash]);
        return names[_buildingHash];
    }

    function getHash(uint256 _nonce) 
        public
        view
        returns (bytes32)
    { 
        return buildingHashes[_nonce];
    }

    function setStone(bytes32 _buildingHash, uint256 _amount) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        stone[_buildingHash] = _amount;
    }

    function setGold(bytes32 _buildingHash, uint256 _amount) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        gold[_buildingHash] = _amount;
    }

    function setActionTimeout(bytes32 _buildingHash, uint256 _actionTimeout) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        actionTimeout[_buildingHash] = _actionTimeout;
    }

    function setWood(bytes32 _buildingHash, uint256 _amount) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);
        wood[_buildingHash] = _amount;
    }

    function getAction(bytes32 _buildingHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return action[_buildingHash];
    }

    function getWood(bytes32 _buildingHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return wood[_buildingHash];
    }

    function getIndexLength() 
        public
        view
        returns (uint256)
    { 
        return buildingHashes.length;
    }

    function getStone(bytes32 _buildingHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return stone[_buildingHash];
    }

    function getGold(bytes32 _buildingHash) 
        public
        view
        returns (uint256)
    { 
        require(exists[_buildingHash]);
        return gold[_buildingHash];
    }

    function transferOwnership(address newOwner) 
        public
    { 
        require(msg.sender == owner);
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setName(bytes32 _buildingHash, bytes16 _name) 
        public
    { 
        require(msg.sender == owner);
        require(exists[_buildingHash]);

        names[_buildingHash] = _name;
    }

    function getActionValue(bytes32 _buildingHash) 
        public
        view
        returns (bytes32)
    { 
        require(exists[_buildingHash]);
        return actionValue[_buildingHash];
    }
}
