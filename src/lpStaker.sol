pragma solidity ^0.8.10;

interface LpTokenStaker {
    event LpTokenStaked(address indexed account, uint256 amount);
    event LpTokenUnstaked(address indexed account, uint256 amount);
    event Shutdown();
    event TokensClaimed(address indexed pool, uint256 cncAmount);

    function INCREASE_PERIOD() external view returns (uint256);
    function MAX_BOOST() external view returns (uint256);
    function MIN_BOOST() external view returns (uint256);
    function TIME_STARTING_FACTOR() external view returns (uint256);
    function TVL_FACTOR() external view returns (uint256);
    function _getTotalStakedForUserCommonDenomination(address account) external view returns (uint256, uint256);
    function boosts(address) external view returns (uint256 timeBoost, uint256 lastUpdated);
    function checkpoint(address pool) external returns (uint256);
    function claimCNCRewardsForPool(address pool) external;
    function claimableCnc(address pool) external view returns (uint256);
    function cnc() external view returns (address);
    function controller() external view returns (address);
    function emergencyMinter() external view returns (address);
    function getBalanceForPool(address conicPool) external view returns (uint256);
    function getBoost(address user) external view returns (uint256);
    function getCachedBoost(address user) external view returns (uint256);
    function getTimeToFullBoost(address user) external view returns (uint256);
    function getUserBalanceForPool(address conicPool, address account) external view returns (uint256);
    function isShutdown() external view returns (bool);
    function poolLastUpdated(address) external view returns (uint256);
    function poolShares(address) external view returns (uint256);
    function renounceMinterRights() external;
    function shutdown() external;
    function stake(uint256 amount, address conicPool) external;
    function stakeFor(uint256 amount, address conicPool, address account) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function unstake(uint256 amount, address conicPool) external;
    function unstakeFor(uint256 amount, address conicPool, address account) external;
    function unstakeFrom(uint256 amount, address account) external;
    function updateBoost(address user) external;
}
