// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/IConicPoolV2.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../src/curve.sol";
import "../src/RewardManager.sol";
import "../src/lpStaker.sol";
import "../src/IUniv3.sol";

contract ConicTest is Test {
    using SafeERC20 for IERC20;
    IERC20 public constant weth =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant usdc =
        IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public constant cnc =
        IERC20(0x9aE380F0272E2162340a5bB646c354271c0F5cFC);
    IERC20 public constant crv =
        IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
    IERC20 public constant cvx =
        IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    IERC20 public constant cncUSDC =
        IERC20(0x472fCC880F01B32C55F1fB55F58f7bD930dE1944);
    IConicPoolV2 public conic =
        IConicPoolV2(0x07b577f10d4e00f3018542d08a87F255a49175A5);
    LpTokenStaker public staker =
        LpTokenStaker(0xeC037423A61B634BFc490dcc215236349999ca3d);
    ICurveFi public cnceth =
        ICurveFi(0x838af967537350D2C44ABB8c010E49E32673ab94);
    ICurveFi public crveth =
        ICurveFi(0x8301AE4fc9c624d1D396cbDAa1ed877821D7C511);
    ICurveFi public cvxeth =
        ICurveFi(0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4);
    RewardManager public rewards =
        RewardManager(0xE976F643d4dc08Aa3CeD55b0CA391B1d11328347);
    IUniV3 public IUniv3 = IUniV3(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    address user = address(1);

    function test_deal() public {
        deal(address(usdc), address(this), 10);
        assertGt(usdc.balanceOf(address(this)), 0);
    }

    function test_main() public {
        uint256 amount = 10_00 * 1e6;
        deal(address(usdc), address(this), amount);
        console.log(usdc.balanceOf(address(this)));
        usdc.approve(address(conic), amount);
        conic.depositFor(address(this), amount, 100000, true);

        skip(10 days);
        rewards.claimEarnings();
        console.log(crv.balanceOf(address(this)));
        console.log(cvx.balanceOf(address(this)));
        console.log(cnc.balanceOf(address(this)));

        uint256 cnc_bal = cnc.balanceOf(address(this));
        cnc.approve(address(cnceth), type(uint256).max);

        cnceth.exchange(1, 0, cnc_bal, 0);
        uint256 crv_bal = crv.balanceOf(address(this));
        crv.approve(address(crveth), type(uint256).max);
        crveth.exchange(1, 0, crv_bal, 0);

        uint256 cvx_bal = cvx.balanceOf(address(this));
        cvx.approve(address(cvxeth), type(uint256).max);
        cvxeth.exchange(1, 0, cvx_bal, 0);

        console.log(cnc.balanceOf(address(this)));
        console.log(cvx.balanceOf(address(this)));
        console.log(crv.balanceOf(address(this)));
        console.log(weth.balanceOf(address(this)));

        uint256 weth_bal = weth.balanceOf(address(this));
        weth.approve(address(IUniv3), type(uint256).max);
        uint24 uniStableFee = 500;
        if (weth_bal > 0) {
            IUniv3.exactInput(
                IUniV3.ExactInputParams(
                    abi.encodePacked(
                        address(weth),
                        uint24(uniStableFee),
                        address(usdc)
                    ),
                    address(this),
                    block.timestamp,
                    weth_bal,
                    uint256(1)
                )
            );
        }
        uint256 toWithdraw = staker.getUserBalanceForPool(
            address(conic),
            address(this)
        );
        conic.unstakeAndWithdraw(toWithdraw, 0);
        uint256 amountAfter = usdc.balanceOf(address(this));
        console.log(usdc.balanceOf(address(this)));
        assertGt(amountAfter, amount);
    }
}
