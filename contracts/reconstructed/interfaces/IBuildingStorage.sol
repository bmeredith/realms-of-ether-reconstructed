pragma solidity 0.4.18;

interface IBuildingStorage {
    function createBuilding(bytes32 _buildingHash) external;
    function setName(bytes32 _buildingHash, bytes16 _name) external;
    function setAction(bytes32 _buildingHash, uint256 _action) external;
    function setActionRate(bytes32 _buildingHash, uint256 _actionRate) external;
    function setActionValue(bytes32 _buildingHash, bytes32 _actionValue) external;
    function setActionTimeout(bytes32 _buildingHash, uint256 _actionTimeout) external;
    function setGold(bytes32 _buildingHash, uint256 _amount) external;
    function setWood(bytes32 _buildingHash, uint256 _amount) external;
    function setStone(bytes32 _buildingHash, uint256 _amount) external;
    function getName(bytes32 _buildingHash) external view returns (bytes16);
    function getAction(bytes32 _buildingHash) external view returns (uint256);
    function getActionRate(bytes32 _buildingHash) external view returns (uint256);
    function getActionValue(bytes32 _buildingHash) external view returns (bytes32);
    function getActionTimeout(bytes32 _buildingHash) external view returns (uint256);
    function getGold(bytes32 _buildingHash) external view returns (uint256);
    function getWood(bytes32 _buildingHash) external view returns (uint256);
    function getStone(bytes32 _buildingHash) external view returns (uint256);
    function getHash(uint256 _nonce) external view returns (bytes32);
    function getIndexLength() external view returns (uint256);
    function transferOwnership(address newOwner) external;
}