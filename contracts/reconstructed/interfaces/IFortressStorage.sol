pragma solidity 0.4.18;

interface IFortressStorage {
    function createFortress(bytes32 _fortressHash, address _user) external;
    function startMinting() external;
    function setName(bytes32 _fortressHash, bytes16 _name) external;
    function setOwner(bytes32 _fortressHash, address _newOwner) external;
    function setX(bytes32 _fortressHash, int256 _x) external;
    function setY(bytes32 _fortressHash, int256 _y) external;
    function setWins(bytes32 _fortressHash, uint256 _wins) external;
    function setGold(bytes32 _fortressHash, uint256 _amount) external;
    function setStone(bytes32 _fortressHash, uint256 _amount) external;
    function setWood(bytes32 _fortressHash, uint256 _amount) external;
    function setBuildingLevel(bytes32 _fortressHash, bytes32 _buildingHash, uint256 _level) external;
    function setBuildingTimeout(bytes32 _fortressHash, bytes32 _buildingHash, uint256 _timeout) external;
    function setTroups(bytes32 _fortressHash, bytes32 _troupHash, uint256 _amount) external;
    function getName(bytes32 _fortressHash) external view returns (bytes16);
    function getOwner(bytes32 _fortressHash) external view returns (address);
    function getX(bytes32 _fortressHash) external view returns (int256);
    function getY(bytes32 _fortressHash) external view returns (int256);
    function getWins(bytes32 _fortressHash) external view returns (uint256);
    function getFortressesAvailable() external view returns (uint256);
    function getFortressCount() external view returns (uint256);
    function getGold(bytes32 _fortressHash) external view returns (uint256);
    function getStone(bytes32 _fortressHash) external view returns (uint256);
    function getWood(bytes32 _fortressHash) external view returns (uint256);
    function getBuildingLevel(bytes32 _fortressHash, bytes32 _buildingHash) external view returns (uint256);
    function getBuildingTimeout(bytes32 _fortressHash, bytes32 _buildingHash) external view returns (uint256);
    function getTroups(bytes32 _fortressHash, bytes32 _troupHash) external view returns (uint256);
    function getIndexLength(address _user) external view returns (uint256);
    function getHashFromIndex(address _user, uint256 _index) external view returns (bytes32);
    function transferOwnership(address newOwner) external;
}
