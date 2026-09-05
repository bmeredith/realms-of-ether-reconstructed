pragma solidity 0.4.18;

import {ITroupStorage} from "./interfaces/ITroupStorage.sol";

/// @title TroupStorageProxy for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Logic library contract for troup management in Realms of Ether.
/// Called via delegatecall from the main game contract, allowing the main
/// game contract to interact with TroupStorage using its own execution context.
/// Also provides read-only convenience functions (getTroup, getCosts)
/// that can be called directly.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
library TroupStorageProxy {
    function getTroup(address _troupStorage, bytes32 _troupHash)
        public
        view
        returns (
            bytes16,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            ITroupStorage(_troupStorage).getName(_troupHash),
            ITroupStorage(_troupStorage).getLife(_troupHash),
            ITroupStorage(_troupStorage).getStrength(_troupHash),
            ITroupStorage(_troupStorage).getIntelligence(_troupHash),
            ITroupStorage(_troupStorage).getDexterity(_troupHash)
        );
    }

    function createTroup(
        address _troupStorage, 
        bytes32 _troupHash, 
        bytes16 _name, 
        uint256 _life, 
        uint256 _strength, 
        uint256 _intelligence, 
        uint256 _dexterity, 
        uint256 _gold, 
        uint256 _wood, 
        uint256 _stone
    ) 
        public
    { 
        ITroupStorage(_troupStorage).createTroup(_troupHash);
        ITroupStorage(_troupStorage).setName(_troupHash, _name);
        ITroupStorage(_troupStorage).setLife(_troupHash, _life);
        ITroupStorage(_troupStorage).setStrength(_troupHash, _strength);
        ITroupStorage(_troupStorage).setIntelligence(_troupHash, _intelligence);
        ITroupStorage(_troupStorage).setDexterity(_troupHash, _dexterity);
        ITroupStorage(_troupStorage).setGold(_troupHash, _gold);
        ITroupStorage(_troupStorage).setWood(_troupHash, _wood);
        ITroupStorage(_troupStorage).setStone(_troupHash, _stone);
    }

    function upgrade(address proxy, address implementation) 
        public
    { 
        ITroupStorage(proxy).transferOwnership(implementation);
    }

    function getHash(address _troupStorage, uint256 _nonce) 
        public
        view
        returns (bytes32)
    {
        return ITroupStorage(_troupStorage).getHash(_nonce);
    }

    function getIndexLength(address _troupStorage) 
        public
        view
        returns (uint256)
    { 
        return ITroupStorage(_troupStorage).getIndexLength();
    }

    /// @dev Returns (gold, stone, wood) — note stone and wood are swapped
    /// compared to the (gold, wood, stone) ordering used elsewhere in the codebase
    function getCosts(address _troupStorage, bytes32 _troupHash) 
        public
        view
        returns (uint256, uint256, uint256)
    { 
        return (
            ITroupStorage(_troupStorage).getGold(_troupHash),
            ITroupStorage(_troupStorage).getStone(_troupHash),
            ITroupStorage(_troupStorage).getWood(_troupHash)
        );
    }
}