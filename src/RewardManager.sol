pragma solidity ^0.8.10;

interface RewardManager {
    event ClaimedRewards(uint256 claimedCrv, uint256 claimedCvx);
    event EarningsClaimed(address indexed claimedBy, uint256 cncEarned, uint256 crvEarned, uint256 cvxEarned);
    event ExtraRewardAdded(address reward);
    event ExtraRewardRemoved(address reward);
    event ExtraRewardsCurvePoolSet(address extraReward, address curvePool);
    event FeesEnabled(uint256 feePercentage);
    event FeesSet(uint256 feePercentage);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SoldRewardTokens(uint256 targetTokenReceived);

    function CNC() external view returns (address);
    function CNC_ETH_POOL() external view returns (address);
    function CRV() external view returns (address);
    function CVX() external view returns (address);
    function MAX_FEE_PERCENTAGE() external view returns (uint256);
    function SLIPPAGE_THRESHOLD() external view returns (uint256);
    function SUSHISWAP() external view returns (address);
    function WETH() external view returns (address);
    function accountCheckpoint(address account) external;
    function addBatchExtraRewards(address[] memory _rewards) external;
    function addExtraReward(address reward) external returns (bool);
    function claimEarnings() external returns (uint256, uint256, uint256);
    function claimPoolEarningsAndSellRewardTokens() external;
    function claimableRewards(address account)
        external
        view
        returns (uint256 cncRewards, uint256 crvRewards, uint256 cvxRewards);
    function controller() external view returns (address);
    function extraRewardsCurvePool(address) external view returns (address);
    function feePercentage() external view returns (uint256);
    function feesEnabled() external view returns (bool);
    function listExtraRewards() external view returns (address[] memory);
    function locker() external view returns (address);
    function lpToken() external view returns (address);
    function owner() external view returns (address);
    function pool() external view returns (address);
    function poolCheckpoint() external returns (bool);
    function removeExtraReward(address tokenAddress) external;
    function renounceOwnership() external;
    function setExtraRewardsCurvePool(address extraReward_, address curvePool_) external;
    function setFeePercentage(uint256 _feePercentage) external;
    function transferOwnership(address newOwner) external;
    function underlying() external view returns (address);
}
