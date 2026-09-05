pragma solidity 0.4.18;

interface ITroupStorage {
    function createTroup(bytes32 _troupHash) external;
    function setName(bytes32 _troupHash, bytes16 _name) external;
    function setLife(bytes32 _troupHash, uint256 _amount) external;
    function setStrength(bytes32 _troupHash, uint256 _amount) external;
    function setIntelligence(bytes32 _troupHash, uint256 _amount) external;
    function setDexterity(bytes32 _troupHash, uint256 _amount) external;
    function setGold(bytes32 _troupHash, uint256 _amount) external;
    function setWood(bytes32 _troupHash, uint256 _amount) external;
    function setStone(bytes32 _troupHash, uint256 _amount) external;
    function getName(bytes32 _troupHash) external view returns (bytes16);
    function getLife(bytes32 _troupHash) external view returns (uint256);
    function getStrength(bytes32 _troupHash) external view returns (uint256);
    function getIntelligence(bytes32 _troupHash) external view returns (uint256);
    function getDexterity(bytes32 _troupHash) external view returns (uint256);
    function getGold(bytes32 _troupHash) external view returns (uint256);
    function getWood(bytes32 _troupHash) external view returns (uint256);
    function getStone(bytes32 _troupHash) external view returns (uint256);
    function getHash(uint256 _nonce) external view returns (bytes32);
    function getIndexLength() external view returns (uint256);
    function transferOwnership(address newOwner) external;
}