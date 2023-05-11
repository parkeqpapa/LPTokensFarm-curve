// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "../src/uniswap.sol";

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

interface ICurveFi {
    function add_liquidity(
        uint256[3] calldata _amounts,
        uint256 _min_mint_amount
    ) external;

    function remove_liquidity(
        uint256 _amount,
        uint256[2] calldata amounts
    ) external;
}

interface IGauge {
    function deposit(uint256) external;

    function balanceOf(address) external view returns (uint256);

    function claim_rewards() external;
}

interface IGaugeFactory {
    function mint(address gauge) external;
}

contract LPTokenFarm is Test {
    using stdStorage for StdStorage;
    IERC20 public constant dai =
        IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant weth =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 public constant crv =
        IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
    IERC20 public constant lptoken =
        IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    ICurveFi public constant pool =
        ICurveFi(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IGauge public constant gauge =
        IGauge(0xbFcF63294aD7105dEa65aA58F8AE5BE2D9d0952A);
    IGaugeFactory public constant minter =
        IGaugeFactory(0xd061D61a4d941c39E5453435B6345Dc261C2fcE0);
    IUniswapV2Router02 public constant sushi =
        IUniswapV2Router02(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

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
        assertEq(dai.balanceOf(address(this)), 0);
        WriteTokenBalance(address(this), address(dai), 1_000_000_000 * 1e18);
        assertGt(dai.balanceOf(address(this)), 0);
    }

    function logBalances() internal view {
        console.log("dai Balance", dai.balanceOf(address(this)));
        console.log("lptoken Balance", lptoken.balanceOf(address(this)));
        console.log("crv Balance", crv.balanceOf(address(this)));
        console.log("Tokens in Gauge", gauge.balanceOf(address(this)));
    }

    function test_farm_lptokens() public {
        WriteTokenBalance(address(this), address(dai), 10_000 * 1e18);
        console.log("Initial DAI Balance");
        logBalances();

        uint256 dai_bal = dai.balanceOf(address(this));

        dai.approve(address(pool), dai_bal);

        pool.add_liquidity([dai_bal, 0, 0], 0);

        console.log("lpToken minted to our account");
        logBalances();

        uint256 lp_bal = lptoken.balanceOf(address(this));
        lptoken.approve(address(gauge), lp_bal);
        gauge.deposit(lp_bal);

        console.log(
            "depositing lptokens to the Curve Gauge and skipping some days in order to get rewards"
        );
        logBalances();

        skip(1 days);

        minter.mint(address(gauge));
        console.log("our rewards were minted!");
        logBalances();

        uint256 crv_bal = crv.balanceOf(address(this));
        crv.approve(address(sushi), crv_bal);

        console.log("swap CRV tokens for more DAI in sushiswap");

        address[] memory path = new address[](3);
        path[0] = address(crv);
        path[1] = address(weth);
        path[2] = address(dai);
        IUniswapV2Router02(sushi).swapExactTokensForTokens(
            crv_bal,
            uint256(0),
            path,
            address(this),
            block.timestamp
        );

        console.log("final DAI farmed");
        logBalances();
    }
}
