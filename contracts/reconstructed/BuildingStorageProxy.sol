pragma solidity 0.4.18;

import {IBuildingStorage} from "./interfaces/IBuildingStorage.sol";

/// @title BuildingStorageProxy for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Logic library contract for building management in Realms of Ether.
/// Called via delegatecall from the main game contract, allowing the main
/// game contract to interact with BuildingStorage using its own execution context.
/// Also provides read-only convenience functions (getBuilding, getCosts)
/// that can be called directly.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
library BuildingStorageProxy {
    function upgrade(address proxy, address implementation) 
        public
    { 
        IBuildingStorage(proxy).transferOwnership(implementation);
    }

    function getBuilding(
        address _buildingStorage, 
        bytes32 _buildingHash
    ) 
        public
        returns (
            bytes16,
            uint256,
            uint256,
            bytes32,
            uint256
        )
    { 
        return (
            IBuildingStorage(_buildingStorage).getName(_buildingHash),
            IBuildingStorage(_buildingStorage).getAction(_buildingHash),
            IBuildingStorage(_buildingStorage).getActionRate(_buildingHash),
            IBuildingStorage(_buildingStorage).getActionValue(_buildingHash),
            IBuildingStorage(_buildingStorage).getActionTimeout(_buildingHash)
        );
    }

    function getHash(
        address _buildingStorage, 
        uint256 _nonce
    ) 
        public
        returns (bytes32)
    { 
        return IBuildingStorage(_buildingStorage).getHash(_nonce);
    }

    function createBuilding(
        address _buildingStorage, 
        bytes32 _buildingHash, 
        bytes16 _name, 
        uint256 _action, 
        uint256 _actionRate, 
        bytes32 _actionValue, 
        uint256 _actionTimeout, 
        uint256 _gold, 
        uint256 _wood, 
        uint256 _stone
    ) 
        public
    { 
        IBuildingStorage(_buildingStorage).createBuilding(_buildingHash);
        IBuildingStorage(_buildingStorage).setName(_buildingHash, _name);
        IBuildingStorage(_buildingStorage).setAction(_buildingHash, _action);
        IBuildingStorage(_buildingStorage).setActionRate(_buildingHash, _actionRate);
        IBuildingStorage(_buildingStorage).setActionValue(_buildingHash, _actionValue);
        IBuildingStorage(_buildingStorage).setActionTimeout(_buildingHash, _actionTimeout);
        IBuildingStorage(_buildingStorage).setGold(_buildingHash, _gold);
        IBuildingStorage(_buildingStorage).setWood(_buildingHash, _wood);
        IBuildingStorage(_buildingStorage).setStone(_buildingHash, _stone);
    }

    function getIndexLength(address _buildingStorage) 
        public
        returns (uint256)
    { 
        return IBuildingStorage(_buildingStorage).getIndexLength();
    }

    function getCosts(
        address _buildingStorage,
        bytes32 _buildingHash
    ) 
        public
        returns (uint256, uint256, uint256)
    { 
        return (
            IBuildingStorage(_buildingStorage).getGold(_buildingHash),
            IBuildingStorage(_buildingStorage).getStone(_buildingHash),
            IBuildingStorage(_buildingStorage).getWood(_buildingHash)
        );
    }
}