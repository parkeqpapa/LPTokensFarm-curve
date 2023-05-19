// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/usdcmarket.sol";
import "../src/rewards.sol";
import "../src/IUniv3.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

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

    uint24 internal constant uniFeeWETH = 3_000;
    uint24 internal constant uniFeeUSDC = 500;

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
        WriteTokenBalance(address(this), address(usdc), 10_000 * 1e18);
        getBalances();

        uint256 usdc_bal = usdc.balanceOf(address(this));

        usdc.approve(address(exactly), usdc_bal);

        exactly.deposit(usdc_bal, address(this));

        uint256 exa_bal = exactly.balanceOf(address(this));

        getBalances();

        skip(1 days);

        rewards.claimAll(address(this));
        exactly.redeem(exa_bal, address(this), address(this));

        uint256 op_bal = op.balanceOf(address(this));

        op.approve(address(uniswap), type(uint256).max);

        getBalances();
        IUniV3(uniswap).exactInput(
            IUniV3.ExactInputParams(
                abi.encodePacked(
                    address(op),
                    uniFeeWETH,
                    address(weth),
                    uniFeeUSDC,
                    address(usdc)
                ),
                address(this),
                block.timestamp,
                1000,
                uint256(1)
            )
        );
    }
}
