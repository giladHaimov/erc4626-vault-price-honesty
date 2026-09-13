// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockAsset} from "../src/test-vaults/MockAsset.sol";
import {CorrectOzVault} from "../src/test-vaults/CorrectOzVault.sol";
import {FailedStaleNavVault} from "../src/test-vaults/FailedStaleNavVault.sol";
import {FixturesReport} from "../src/report/FixturesReport.sol";

/// @notice Measurable helper gap: balance - totalAssets. StaleNav opens on gift, closes on poke.
contract HelperGapTest is Test {
    MockAsset internal asset;
    address internal alice = makeAddr("alice");
    address internal donor = makeAddr("donor");

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
        asset.mint(alice, 50_000e18);
        asset.mint(donor, 50_000e18);
    }

    function test_FailedStaleNav_gapOpensAndCloses() public {
        FailedStaleNavVault vault = new FailedStaleNavVault(IERC20(address(asset)));

        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(5_000e18, alice);
        vm.stopPrank();

        uint256 gift = 2_500e18;
        vm.prank(donor);
        asset.transfer(address(vault), gift);

        uint256 bal = asset.balanceOf(address(vault));
        uint256 ta = vault.totalAssets();
        uint256 gap = bal - ta;
        assertGt(gap, 0, "gap open after gift");
        assertEq(gap, gift);

        vault.poke();
        uint256 gapAfter = asset.balanceOf(address(vault)) - vault.totalAssets();
        assertEq(gapAfter, 0, "gap closes after poke");

        FixturesReport.row(
            "FailedStaleNavVault",
            "HelperGap",
            "ran",
            string.concat(
                "balance=",
                FixturesReport.e18(bal),
                " totalAssets=",
                FixturesReport.e18(ta),
                " gapOpen=",
                FixturesReport.e18(gap),
                " gapAfterPoke=",
                FixturesReport.e18(gapAfter)
            ),
            "gap open then closed (stale cache)",
            "none named (architecture/stale cache, not a helper lie)"
        );
    }

    function test_Baseline_noHelperGap_NA() public {
        CorrectOzVault vault = new CorrectOzVault(IERC20(address(asset)));

        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(5_000e18, alice);
        vm.stopPrank();

        uint256 gift = 2_500e18;
        vm.prank(donor);
        asset.transfer(address(vault), gift);

        uint256 bal = asset.balanceOf(address(vault));
        uint256 ta = vault.totalAssets();
        assertEq(ta, bal, "Baseline totalAssets == balance; no separate helper");

        FixturesReport.row(
            "CorrectOzVault",
            "HelperGap",
            "N/A",
            string.concat("totalAssets=", FixturesReport.e18(ta), " == balance=", FixturesReport.e18(bal), " (no separate helper)"),
            "N/A (no helper)",
            "none named"
        );
    }
}
