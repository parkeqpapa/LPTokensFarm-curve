// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/usdcmarket.sol";
import "../src/rewards.sol";
import "../src/IUniv3.sol";
import "../src/IVelodromeRouter.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ExactlyFarm is Test {
    using stdStorage for StdStorage;

    IERC20 public constant usdc =
        IERC20(0x7F5c764cBc14f9669B88837ca1490cCa17c31607);
    IERC20 public constant op =
        IERC20(0x4200000000000000000000000000000000000042);
    IERC20 public constant weth =
        IERC20(0x4200000000000000000000000000000000000006);

    Market public constant exactly =
        Market(0x81C9A7B55A4df39A9B7B5F781ec0e53539694873);
    RewardsController public constant rewards =
        RewardsController(0xBd1ba78A3976cAB420A9203E6ef14D18C2B2E031);
    IUniV3 public constant uniswap =
        IUniV3(0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45);

    IVelodromeRouter public constant router =
        IVelodromeRouter(0x9c12939390052919aF3155f41Bf4160Fd3666A6f);

    function WriteTokenBalance(
        address who,
        address token,
        uint256 amt
    ) internal {
        stdstore
            .target(token)
            .sig(IERC20(token).balanceOf.selector)
            .with_key(who)
            .checked_write(amt);
    }

    function testWrite() public {
        assertEq(usdc.balanceOf(address(this)), 0);
        WriteTokenBalance(address(this), address(usdc), 1_000_000_000 * 1e18);
        assertGt(usdc.balanceOf(address(this)), 0);
    }

    function getBalances() internal view {
        console.log("usdc Balances", usdc.balanceOf(address(this)));
        console.log("op rewards earned", op.balanceOf(address(this)));
        console.log("exaUSDC balance", exactly.balanceOf(address(this)));
    }

    function test_farm_exactly() public {
        WriteTokenBalance(address(this), address(usdc), 100 * 1e18);
        getBalances();

        uint256 usdc_bal = usdc.balanceOf(address(this));

        usdc.approve(address(exactly), usdc_bal);

        exactly.deposit(usdc_bal, address(this));

        uint256 exa_bal = exactly.balanceOf(address(this));

        getBalances();

        skip(1 days);

        rewards.claimAll(address(this));
        exactly.redeem(exa_bal, address(this), address(this));
        op.approve(address(router), type(uint256).max);

        uint256 op_bal = op.balanceOf(address(this));
        getBalances();

        router.swapExactTokensForTokensSimple(
            op_bal,
            0,
            address(op),
            address(usdc),
            false,
            address(this),
            block.timestamp
        );
        console.log("final USDC", usdc.balanceOf(address(this)));
    }
}
