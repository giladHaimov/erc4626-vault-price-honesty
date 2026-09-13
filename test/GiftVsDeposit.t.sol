// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockAsset} from "../src/test-vaults/MockAsset.sol";
import {CorrectOzVault} from "../src/test-vaults/CorrectOzVault.sol";
import {FailedStaleNavVault} from "../src/test-vaults/FailedStaleNavVault.sol";
import {FixturesReport} from "../src/report/FixturesReport.sol";

/// @notice Official deposit then plain transfer gift. Baseline counts gifts; StaleNav does not until poke.
contract GiftVsDepositTest is Test {
    MockAsset internal asset;
    address internal alice = makeAddr("alice");
    address internal donor = makeAddr("donor");

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
        asset.mint(alice, 100_000e18);
        asset.mint(donor, 100_000e18);
    }

    function test_Baseline_giftMovesTotalAssets() public {
        CorrectOzVault vault = new CorrectOzVault(IERC20(address(asset)));

        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(10_000e18, alice);
        vm.stopPrank();

        uint256 taBefore = vault.totalAssets();
        uint256 priceBefore = vault.convertToAssets(1e18);
        uint256 gift = 10_000e18;

        vm.prank(donor);
        asset.transfer(address(vault), gift);

        uint256 taAfter = vault.totalAssets();
        uint256 priceAfter = vault.convertToAssets(1e18);
        uint256 bal = asset.balanceOf(address(vault));

        assertEq(taAfter, taBefore + gift, "Baseline totalAssets should count gift");
        assertEq(taAfter, bal);
        assertGt(priceAfter, priceBefore, "share price should rise after gift");

        FixturesReport.row(
            "CorrectOzVault",
            "GiftVsDeposit",
            "ran",
            string.concat(
                "taBefore=",
                FixturesReport.e18(taBefore),
                " taAfterGift=",
                FixturesReport.e18(taAfter),
                " priceBefore=",
                FixturesReport.e18(priceBefore),
                " priceAfter=",
                FixturesReport.e18(priceAfter),
                " gift=",
                FixturesReport.e18(gift)
            ),
            "gifts counted",
            "later depositors pay higher price; existing LPs gain (not theft)"
        );
    }

    function test_FailedStaleNav_giftDoesNotMoveUntilPoke() public {
        FailedStaleNavVault vault = new FailedStaleNavVault(IERC20(address(asset)));

        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(10_000e18, alice);
        vm.stopPrank();

        uint256 taBefore = vault.totalAssets();
        uint256 priceBefore = vault.convertToAssets(1e18);
        uint256 gift = 10_000e18;

        vm.prank(donor);
        asset.transfer(address(vault), gift);

        uint256 taAfterGift = vault.totalAssets();
        uint256 balAfterGift = asset.balanceOf(address(vault));
        uint256 priceAfterGift = vault.convertToAssets(1e18);

        assertEq(taAfterGift, taBefore, "StaleNav totalAssets must ignore gift until poke");
        assertEq(balAfterGift, taBefore + gift);
        assertTrue(taAfterGift != balAfterGift, "totalAssets != balanceOf after gift");
        assertEq(priceAfterGift, priceBefore, "price unchanged until poke");

        vault.poke();
        uint256 taAfterPoke = vault.totalAssets();
        assertEq(taAfterPoke, balAfterGift);

        FixturesReport.row(
            "FailedStaleNavVault",
            "GiftVsDeposit",
            "ran",
            string.concat(
                "taBefore=",
                FixturesReport.e18(taBefore),
                " taAfterGift=",
                FixturesReport.e18(taAfterGift),
                " balanceAfterGift=",
                FixturesReport.e18(balAfterGift),
                " taAfterPoke=",
                FixturesReport.e18(taAfterPoke),
                " gap=",
                FixturesReport.e18(balAfterGift - taAfterGift)
            ),
            "stale cache until poke (architecture/helper-gap)",
            "none named until someone acts on the stale number"
        );
    }
}
