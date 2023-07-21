pragma solidity ^0.8.10;

interface IConicPoolV2 {
    event ClaimedRewards(uint256 claimedCrv, uint256 claimedCvx);
    event CurvePoolAdded(address curvePool_);
    event CurvePoolRemoved(address curvePool_);
    event DepegThresholdUpdated(uint256 newThreshold);
    event Deposit(
        address indexed sender,
        address indexed receiver,
        uint256 depositedAmount,
        uint256 lpReceived
    );
    event HandledDepeggedCurvePool(address curvePool_);
    event HandledInvalidConvexPid(address curvePool_, uint256 pid_);
    event MaxDeviationUpdated(uint256 newMaxDeviation);
    event NewMaxIdleCurveLpRatio(uint256 newRatio);
    event NewWeight(address indexed curvePool, uint256 newWeight);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event Shutdown();
    event Withdraw(address indexed account, uint256 amount);

    struct PoolWeight {
        address poolAddress;
        uint256 weight;
    }

    struct PoolWithAmount {
        address poolAddress;
        uint256 amount;
    }

    function CNC() external view returns (address);

    function CRV() external view returns (address);

    function CVX() external view returns (address);

    function addCurvePool(address _pool) external;

    function allCurvePools() external view returns (address[] memory);

    function cachedTotalUnderlying() external view returns (uint256);

    function computeDeviationRatio() external view returns (uint256);

    function computeTotalDeviation() external view returns (uint256);

    function controller() external view returns (address);

    function curvePoolsCount() external view returns (uint256);

    function depegThreshold() external view returns (uint256);

    function deposit(
        uint256 underlyingAmount,
        uint256 minLpReceived,
        bool stake
    ) external returns (uint256);

    function deposit(
        uint256 underlyingAmount,
        uint256 minLpReceived
    ) external returns (uint256);

    function depositFor(
        address account,
        uint256 underlyingAmount,
        uint256 minLpReceived,
        bool stake
    ) external returns (uint256);

    function exchangeRate() external view returns (uint256);

    function getAllocatedUnderlying()
        external
        view
        returns (PoolWithAmount[] memory);

    function getCurvePoolAtIndex(
        uint256 _index
    ) external view returns (address);

    function getPoolWeight(address _pool) external view returns (uint256);

    function getTotalAndPerPoolUnderlying()
        external
        view
        returns (
            uint256 totalUnderlying_,
            uint256 totalAllocated_,
            uint256[] memory perPoolUnderlying_
        );

    function getWeight(address curvePool) external view returns (uint256);

    function getWeights() external view returns (PoolWeight[] memory);

    function handleDepeggedCurvePool(address curvePool_) external;

    function handleInvalidConvexPid(address curvePool_) external;

    function isBalanced() external view returns (bool);

    function isRegisteredCurvePool(address _pool) external view returns (bool);

    function isShutdown() external view returns (bool);

    function lpToken() external view returns (address);

    function maxDeviation() external view returns (uint256);

    function maxIdleCurveLpRatio() external view returns (uint256);

    function owner() external view returns (address);

    function rebalancingRewardActive() external view returns (bool);

    function removeCurvePool(address _pool) external;

    function renounceOwnership() external;

    function rewardManager() external view returns (address);

    function setMaxDeviation(uint256 maxDeviation_) external;

    function setMaxIdleCurveLpRatio(uint256 maxIdleCurveLpRatio_) external;

    function shutdownPool() external;

    function totalCurveLpBalance(
        address curvePool_
    ) external view returns (uint256);

    function totalDeviationAfterWeightUpdate() external view returns (uint256);

    function totalUnderlying() external view returns (uint256);

    function transferOwnership(address newOwner) external;

    function underlying() external view returns (address);

    function unstakeAndWithdraw(
        uint256 conicLpAmount,
        uint256 minUnderlyingReceived
    ) external returns (uint256);

    function updateDepegThreshold(uint256 newDepegThreshold_) external;

    function updateWeights(PoolWeight[] memory poolWeights) external;

    function usdExchangeRate() external view returns (uint256);

    function withdraw(
        uint256 conicLpAmount,
        uint256 minUnderlyingReceived
    ) external returns (uint256);
}
