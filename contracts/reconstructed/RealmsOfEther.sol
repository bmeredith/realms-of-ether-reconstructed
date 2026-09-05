pragma solidity 0.4.18;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

import "./FortressStorageProxy.sol";
import "./BuildingStorageProxy.sol";
import "./TroupStorageProxy.sol";

/// @title Main game contract for Realms of Ether (https://www.realmsofether.com)
/// @notice Reconstructed by wilt.eth/@wilty_stilty
///
/// @notice Realms of Ether is an on-chain strategy game. Players buy fortresses,
/// which produce gold, stone and wood, spend those resources to build and level
/// up buildings, train troups, and trade fortresses via a built-in auction.
/// All game state lives in three separate storage contracts (FortressStorage,
/// BuildingStorage, TroupStorage). This contract holds the rules and reaches
/// the storage through three delegatecall'd libraries (FortressStorageProxy,
/// BuildingStorageProxy, TroupStorageProxy), so the game logic could be
/// replaced via upgradeGame() without migrating state.
///
/// Why only 500 fortresses exist: Realms of Ether was designed to start with
/// 1,000 fortresses and add one every 15 minutes after minting began. But 
/// FortressStorage.createFortress checks getFortressesAvailable() > getFortressCount()
/// and getFortressesAvailable() is already "supply minus minted". Requiring it 
/// to exceed the minted count means minting stops at half the supply: 500. 
/// Minting was never started (genesisTime is still 0), so the cap never grew.
///
/// @dev RECONSTRUCTION NOTICE: The original source code for this contract was lost.
/// This file has been reconstructed in its entirety from the deployed bytecode.
contract RealmsOfEther is Pausable {
    using SafeMath for uint256;
    
    /// @dev Monotonic counter mixed into every fortress/building/troup hash
    uint256 nonce;

    /// @notice Address of the FortressStorage contract.
    address public fortressStorage;

    /// @notice Address of the BuildingStorage contract.
    address public buildingStorage;

    /// @notice Address of the TroupStorage contract.
    address public troupStorage;

    /// @notice keccak256("Gold"), set in the constructor. Buildings whose
    /// actionValue equals this hash produce gold.
    bytes32 public goldHash;

    /// @notice keccak256("Wood").
    bytes32 public woodHash;

    /// @notice keccak256("Stone").
    bytes32 public stoneHash;

    /// @notice Timestamp at which bidding closes (start + 3 days).
    mapping(bytes32 => uint256) public auctionEnd;

    /// @notice The player who put the fortress up for auction and who
    /// receives the winning bid.
    mapping(bytes32 => address) public auctionOwner;

    /// @notice Current highest cumulative bid in wei.
    mapping(bytes32 => uint256) public highestBid;

    /// @notice Address holding the highest bid. Initialised to the auction
    /// owner so an auction with no bids ends by returning the fortress.
    mapping(bytes32 => address) public highestBidder;

    /// @notice Every auction a user has started or bid on, in order. Entries
    /// are never removed.
    mapping(address => bytes32[]) public userAuctions;

    /// @notice Cumulative amount a bidder has locked in an auction, keyed by
    /// keccak256(fortressHash, bidder). See getAuctionAmount for the
    /// convenience accessor.
    mapping(bytes32 => uint256) public balanceAuction;

    /// @notice Total wei a user has locked across all auctions (bids minus
    /// withdrawals plus proceeds from auctions they won or sold).
    mapping(address => uint256) public balances;

    /// @notice Sum of all balances; everything above this in the contract's
    /// ETH balance is fortress-sale income and the 1% bid fee, withdrawable
    /// by the owner via withdrawExcess.
    uint256 public totalBalance;

    /// @notice Every auction ever started, in order.
    bytes32[] public auctions;

    // Map placement. New fortresses are placed on a square spiral walking
    // outward from the origin: (0,0), (1,0), (1,-1), (0,-1), (-1,-1), ...
    // x/y is the coordinate the next fortress will receive, dx/dy the
    // current direction of travel. Names chosen by the reconstructor;
    int256 x = 0;
    int256 y = 0;
    int256 dx = 0;
    int256 dy = -1;

    event LogFortressCreated(bytes16 name, bytes32 hash, address owner, int256 x, int256 y);
    event LogBuild(bytes32 fortressHash, bytes32 buildingHash);
    event LogBuildingAction(bytes32 fortressHash, bytes32 buildingHash);
    event LogBuildingCreated(bytes32 buildingHash);
    event LogTroupCreated(bytes32 troupHash);

    function RealmsOfEther(
        address _fortressStorage,
        address _troupStorage,
        address _buildingStorage
    )
        public
    {
        fortressStorage = _fortressStorage;
        troupStorage = _troupStorage;
        buildingStorage = _buildingStorage;
        goldHash = keccak256("Gold");
        woodHash = keccak256("Wood");
        stoneHash = keccak256("Stone");
    }

    function requireFortressOwner(bytes32 _fortressHash)
        internal
        view
    {
        require(FortressStorageProxy.getOwner(fortressStorage, _fortressHash) == msg.sender);
    }

    /// @notice Raise a building one level. Cost is the building's base cost
    /// multiplied by the new level, deducted from the fortress's resources.
    function createFortress(bytes16 _name)
        public
        payable
        whenNotPaused
    {
        require(msg.value >= 10 finney);

        bytes32 fortressHash = keccak256(msg.sender, _name, nonce);
        FortressStorageProxy.createFortress(fortressStorage, fortressHash, _name, x, y, 200, 400, 500, 0, msg.sender);

        // Faithful to the original: the position is advanced before the
        // event, so the event carries the coordinates of the next fortress.
        updatePosition();

        LogFortressCreated(_name, fortressHash, msg.sender, x, y);
        nonce++;
    }

    // Square-spiral walk over the map.
    function updatePosition()
        internal
    {
        if (x == y || (x < 0 && x == -y) || (x > 0 && x == 1 - y)) {
            int256 temp = dx;
            dx = -dy;
            dy = temp;
        }

        x += dx;
        y += dy;
    }

    function transferFortress(
        bytes32 _fortressHash,
        address _newOwner
    )
        public
        whenNotPaused
    {
        requireFortressOwner(_fortressHash);

        FortressStorageProxy.transfer(fortressStorage, _fortressHash, _newOwner);
    }

    function startMinting()
        public
        onlyOwner
    {
        FortressStorageProxy.startMinting(fortressStorage);
    }

    function getFortress(bytes32 _fortressHash)
        public
        view
        returns (
            bytes16 _name,
            address _owner,
            int256 _x,
            int256 _y,
            uint256 _wins
        ) 
    {
        return FortressStorageProxy.getFortress(fortressStorage, _fortressHash);
    }

    function getResources(bytes32 _fortressHash)
        public
        view
        returns (
            uint256 _gold,
            uint256 _stone,
            uint256 _wood
        )
    {
        return FortressStorageProxy.getResources(fortressStorage, _fortressHash);
    }

    function getFortressBuilding(
        bytes32 _fortressHash,
        bytes32 _buildingHash
    ) 
        public
        view
        returns (
            uint256 _level,
            uint256 _timeout
        )
    {
        return FortressStorageProxy.getBuilding(fortressStorage, _fortressHash, _buildingHash);
    }

    function getFortressTroups(
        bytes32 _fortressHash,
        bytes32 _troupHash
    ) 
        public
        view
        returns (
            uint256 _amount
        )
    {
        return FortressStorageProxy.getTroups(fortressStorage, _fortressHash, _troupHash);
    }

    function getFortressCount() 
        public
        view
        returns (uint256)
    {
        return FortressStorageProxy.getFortressCount(fortressStorage);
    }

    function getFortressesAvailable()
        public
        view
        returns (uint256)
    {
        return FortressStorageProxy.getFortressesAvailable(fortressStorage);
    }

    function getHashFromIndex(
        address _user,
        uint256 _index
    )
        public
        view
        returns (bytes32)
    {
        return FortressStorageProxy.getHashFromIndex(fortressStorage, _user, _index);
    }

    function getIndexLength(address _user)
        public
        view
        returns (uint256)
    {
        return FortressStorageProxy.getIndexLength(fortressStorage, _user);
    }

    function createBuilding(
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
        onlyOwner
    {
        bytes32 buildingHash = keccak256(msg.sender, _name, nonce);
        BuildingStorageProxy.createBuilding(buildingStorage, buildingHash, _name, _action, _actionRate, _actionValue, _actionTimeout, _gold, _wood, _stone);

        LogBuildingCreated(buildingHash);
        nonce++;
    }

    function getBuilding(bytes32 _buildingHash)
        public
        view
        returns (
            bytes16 _name,
            uint256 _action,
            uint256 _actionRate,
            bytes32 _actionValue,
            uint256 _actionTimeout
        )
    {
        return BuildingStorageProxy.getBuilding(buildingStorage, _buildingHash);
    }

    function getBuildingCosts(bytes32 _buildingHash)
        public
        view
        returns (
            uint256 _gold,
            uint256 _stone,
            uint256 _wood
        )
    {
        return BuildingStorageProxy.getCosts(buildingStorage, _buildingHash);
    }

    function getBuildingHash(uint256 _index)
        public
        view
        returns (bytes32)
    {
        return BuildingStorageProxy.getHash(buildingStorage, _index);
    }

    function getBuildingIndexLength()
        public
        view
        returns (uint256)
    {
        return BuildingStorageProxy.getIndexLength(buildingStorage);
    }

    function build(
        bytes32 _fortressHash,
        bytes32 _buildingHash
    ) 
        public
        whenNotPaused
    {
        requireFortressOwner(_fortressHash);

        uint256 gold;
        uint256 stone;
        uint256 wood;
        uint256 goldCost;
        uint256 stoneCost;
        uint256 woodCost;
        uint256 level;
        uint256 timeout;

        (gold, stone, wood) = getResources(_fortressHash);
        (goldCost, stoneCost, woodCost) = getBuildingCosts(_buildingHash);
        (level, timeout) = getFortressBuilding(_fortressHash, _buildingHash);

        level = level.add(1);
        goldCost = goldCost.mul(level);
        stoneCost = stoneCost.mul(level);
        woodCost = woodCost.mul(level);

        require(gold >= goldCost && stone >= stoneCost && wood >= woodCost);

        FortressStorageProxy.build(fortressStorage, _fortressHash, _buildingHash, gold.sub(goldCost), stone.sub(stoneCost), wood.sub(woodCost), level);
        LogBuild(_fortressHash, _buildingHash);
    }

    /// @notice Trigger a building's action once its timeout has passed.
    ///
    /// action == 1: produce (level + 1) * actionRate of the resource named
    /// by actionValue (goldHash / stoneHash / woodHash).
    ///
    /// action == 2: train (level * actionRate + 1) units of the troup whose
    /// hash is actionValue, paying that troup's cost per unit.
    ///
    /// In both cases the building is then locked for actionTimeout hours.
    function buildingAction(
        bytes32 _fortressHash,
        bytes32 _buildingHash
    )
        public
        whenNotPaused 
    {
        requireFortressOwner(_fortressHash);

        uint256 level;
        uint256 timeout;
        bytes16 name;
        uint256 action;
        uint256 actionRate;
        bytes32 actionValue;
        uint256 actionTimeout;
        uint256 gold;
        uint256 stone;
        uint256 wood;

        (level, timeout) = getFortressBuilding(_fortressHash, _buildingHash);
        require(now > timeout);

        (name, action, actionRate, actionValue, actionTimeout) = getBuilding(_buildingHash);
        (gold, stone, wood) = getResources(_fortressHash);

        if (action == 1) {
            produceResources(_fortressHash, actionValue, actionRate, level, gold, stone, wood);
        }
        if (action == 2) {
            uint256 troups = getFortressTroups(_fortressHash, actionValue);
            trainTroups(_fortressHash, actionValue, actionRate, level, gold, stone, wood, troups);
        }

        setBuildingTimeout(_fortressHash, _buildingHash, actionTimeout);
        LogBuildingAction(_fortressHash, _buildingHash);
    }

    function produceResources(
        bytes32 _fortressHash,
        bytes32 _actionValue,
        uint256 _actionRate,
        uint256 _level,
        uint256 _gold,
        uint256 _stone,
        uint256 _wood
    )
        internal
    {
        if (_actionValue == goldHash) {
            _gold = _gold.add(_actionRate.mul(_level.add(1)));
            FortressStorageProxy.setGold(fortressStorage, _fortressHash, _gold);
        }
        if (_actionValue == stoneHash) {
            _stone = _stone.add(_actionRate.mul(_level.add(1)));
            FortressStorageProxy.setStone(fortressStorage, _fortressHash, _stone);
        }
        if (_actionValue == woodHash) {
            _wood = _wood.add(_actionRate.mul(_level.add(1)));
            FortressStorageProxy.setWood(fortressStorage, _fortressHash, _wood);
        }
    }

    function trainTroups(
        bytes32 _fortressHash,
        bytes32 _actionValue,
        uint256 _actionRate,
        uint256 _level,
        uint256 _gold,
        uint256 _stone,
        uint256 _wood,
        uint256 _troups
    )
        internal
    {
        var (goldCost, stoneCost, woodCost) = getTroupCosts(_actionValue);
        uint256 amount = _actionRate.mul(_level).add(1);

        goldCost = goldCost.mul(amount);
        stoneCost = stoneCost.mul(amount);
        woodCost = woodCost.mul(amount);

        require(_gold >= goldCost && _stone >= stoneCost && _wood >= woodCost);

        FortressStorageProxy.setGold(fortressStorage, _fortressHash, _gold.sub(goldCost));
        FortressStorageProxy.setStone(fortressStorage, _fortressHash, _stone.sub(stoneCost));
        FortressStorageProxy.setWood(fortressStorage, _fortressHash, _wood.sub(woodCost));
        FortressStorageProxy.setTroups(fortressStorage, _fortressHash, _actionValue, _troups.add(amount));
    }

    function setBuildingTimeout(
        bytes32 _fortressHash,
        bytes32 _buildingHash,
        uint256 _actionTimeout
    ) 
        internal
    {
        FortressStorageProxy.setBuildingTimeout(fortressStorage, _fortressHash, _buildingHash, now + _actionTimeout * 1 hours);
    }

    function createTroup(
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
        onlyOwner
    {
        bytes32 troupHash = keccak256(msg.sender, _name, nonce);
        TroupStorageProxy.createTroup(troupStorage, troupHash, _name, _life, _strength, _intelligence, _dexterity, _gold, _wood, _stone);

        LogTroupCreated(troupHash);
        nonce++;
    }

    function getTroup(bytes32 _troupHash)
        public
        view
        returns (
            bytes16 _name,
            uint256 _life,
            uint256 _strength,
            uint256 _intelligence, 
            uint256 _dexterity
        )
    {
        return TroupStorageProxy.getTroup(troupStorage, _troupHash);
    }

    function getTroupCosts(bytes32 _troupHash)
        public
        view
        returns (
            uint256 _gold,
            uint256 _stone,
            uint256 _wood
        )
    {
        return TroupStorageProxy.getCosts(troupStorage, _troupHash);
    }

    function getTroupHash(uint256 _index)
        public
        view
        returns (bytes32)
    {
        return TroupStorageProxy.getHash(troupStorage, _index);
    }

    function getTroupIndexLength()
        public
        view
        returns (uint256)
    {
        return TroupStorageProxy.getIndexLength(troupStorage);
    }

    /// @notice Escrow a fortress into this contract and open a 3-day auction.
    /// The seller is recorded as the initial highest bidder with a bid of 0,
    /// so an auction with no bids can be closed by the seller via endAuction.
    function startAuction(bytes32 _fortressHash)
        public
        whenNotPaused
    {
        require(FortressStorageProxy.getOwner(fortressStorage, _fortressHash) == msg.sender);
        FortressStorageProxy.setOwner(fortressStorage, _fortressHash, this);

        highestBidder[_fortressHash] = msg.sender;
        highestBid[_fortressHash] = 0;
        auctionOwner[_fortressHash] = msg.sender;
        auctionEnd[_fortressHash] = now + 3 days;

        userAuctions[msg.sender].push(_fortressHash);
        auctions.push(_fortressHash);
    }

    /// @notice Bid on an open auction. Bids are cumulative per bidder; 1% of
    /// each payment is kept as a fee, the rest is credited to the bidder's
    /// balance and locked. A bidder becomes highest bidder once their total
    /// exceeds the current high bid by at least 0.01 ETH.
    function bidAuction(bytes32 _fortressHash)
        public
        payable
        whenNotPaused
    {
        require(now < auctionEnd[_fortressHash]);
        require(now > auctionEnd[_fortressHash].sub(3 days));

        uint256 fee = msg.value.div(100).mul(1); // 1% fee
        uint256 amount = msg.value.sub(fee);
        bytes32 hash = keccak256(_fortressHash, msg.sender);

        if (balanceAuction[hash] == 0) {
            userAuctions[msg.sender].push(_fortressHash);
        }

        balanceAuction[hash] = balanceAuction[hash].add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalBalance = totalBalance.add(amount);

        if (balanceAuction[hash] >= highestBid[_fortressHash].add(10 finney)) {
            highestBid[_fortressHash] = balanceAuction[hash];
            highestBidder[_fortressHash] = msg.sender;
        }
    }

    /// @notice Called by the winner after the auction closes: takes ownership
    /// of the fortress and moves the winning amount from the winner's balance
    /// to the seller's, where it can be withdrawn like any other bid.
    function endAuction(bytes32 _fortressHash)
        public
        whenNotPaused
    {
        require(auctionEnd[_fortressHash] <= now);
        require(highestBidder[_fortressHash] == msg.sender);

        FortressStorageProxy.setOwner(fortressStorage, _fortressHash, msg.sender);

        balances[msg.sender] = balances[msg.sender].sub(highestBid[_fortressHash]);

        bytes32 bidderHash = keccak256(_fortressHash, msg.sender);
        balanceAuction[bidderHash] = 0;

        bytes32 ownerHash = keccak256(_fortressHash, auctionOwner[_fortressHash]);
        balanceAuction[ownerHash] = balanceAuction[ownerHash].add(highestBid[_fortressHash]);
        balances[auctionOwner[_fortressHash]] = balances[auctionOwner[_fortressHash]].add(highestBid[_fortressHash]);
    }

    /// @notice Reclaim a losing bid (or sale proceeds) after the auction closes.
    function withdraw(bytes32 _fortressHash)
        public
        whenNotPaused
    {
        require(auctionEnd[_fortressHash] <= now);
        require(highestBidder[_fortressHash] != msg.sender);

        bytes32 hash = keccak256(_fortressHash, msg.sender);
        uint256 amount = balanceAuction[hash];
        balanceAuction[hash] = 0;

        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalBalance = totalBalance.sub(amount);

        msg.sender.transfer(amount);
    }

    /// @notice Owner withdraws everything not owed to players: fortress
    /// purchase prices and the 1% bid fees.
    function withdrawExcess(address _withdraw)
        public
        onlyOwner
    {
        _withdraw.transfer(this.balance.sub(totalBalance));
    }

    function getAuctionAmount(
        bytes32 _fortressHash,
        address _user
    )
        public
        view
        returns (uint256)
    {
        bytes32 hash = keccak256(_fortressHash, _user);
        return balanceAuction[hash];
    }

    function getAuctionsLength()
        public
        view
        returns (uint256)
    {
        return auctions.length;
    }

    function getUserAuctionsLength(address _user)
        public
        view
        returns (uint256)
    {
        return userAuctions[_user].length;
    }

    /// @notice Hand all three storage contracts to a new game contract.
    /// After this call the current contract can no longer write game state.
    function upgradeGame(address _newContract)
        public
        onlyOwner
    {
        FortressStorageProxy.upgrade(fortressStorage, _newContract);
        BuildingStorageProxy.upgrade(buildingStorage, _newContract);
        TroupStorageProxy.upgrade(troupStorage, _newContract);
    }

    function() public payable {
        revert();
    }
}
