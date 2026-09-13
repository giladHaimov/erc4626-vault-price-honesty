// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {MockAsset} from "../src/fixtures/MockAsset.sol";
import {BaselineVault} from "../src/fixtures/BaselineVault.sol";
import {OffsetVault} from "../src/fixtures/OffsetVault.sol";
import {FixturesReport} from "../src/report/FixturesReport.sol";

/// @notice Empty vault -> attacker 1 wei deposit + large gift -> victim large deposit.
/// @dev OZ v5 uses (supply + 10**offset) / (assets + 1). Even offset 0 has a +1 virtual share.
///      Victim gets 0 shares when 2*victimAssets < donation+2 (offset 0).
contract FirstDepositorTest is Test {
    MockAsset internal asset;
    address internal attacker = makeAddr("attacker");
    address internal victim = makeAddr("victim");

    // donation >> 2*victim so Baseline (offset 0) floors victim shares to 0
    uint256 internal constant DONATION = 10_000e18;
    uint256 internal constant VICTIM_DEPOSIT = 50e18;

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
        asset.mint(attacker, DONATION + 1);
        asset.mint(victim, VICTIM_DEPOSIT);
    }

    function test_Baseline_victimRoundsBadly() public {
        BaselineVault vault = new BaselineVault(IERC20(address(asset)));
        (uint256 attackerShares, uint256 victimShares, uint256 attackerRedeem, uint256 victimRedeem) =
            _runInflation(vault);

        assertEq(victimShares, 0, "Baseline offset0: victim shares floor to 0");

        FixturesReport.row(
            "BaselineVault",
            "FirstDepositor",
            "ran",
            string.concat(
                "attackerShares=",
                FixturesReport.e18(attackerShares),
                " donation=",
                FixturesReport.e18(DONATION),
                " victimDeposit=",
                FixturesReport.e18(VICTIM_DEPOSIT),
                " victimShares=",
                FixturesReport.e18(victimShares),
                " attackerPreviewRedeem=",
                FixturesReport.e18(attackerRedeem),
                " victimPreviewRedeem=",
                FixturesReport.e18(victimRedeem)
            ),
            "victim share count rounds to 0",
            "victim (almost no shares); attacker can redeem nearly the pot"
        );
    }

    function test_Offset_victimGetsMeaningfulShares() public {
        OffsetVault vault = new OffsetVault(IERC20(address(asset)));
        (uint256 attackerShares, uint256 victimShares, uint256 attackerRedeem, uint256 victimRedeem) =
            _runInflation(vault);

        assertGt(victimShares, 0, "OffsetVault: victim should get shares");
        // Same amounts that wipe Baseline to 0 still mint >0 here (offset virtual shares).
        assertGt(victimRedeem, 0, "OffsetVault: victim redeem value > 0");

        FixturesReport.row(
            "OffsetVault",
            "FirstDepositor",
            "ran",
            string.concat(
                "attackerShares=",
                FixturesReport.e18(attackerShares),
                " donation=",
                FixturesReport.e18(DONATION),
                " victimDeposit=",
                FixturesReport.e18(VICTIM_DEPOSIT),
                " victimShares=",
                FixturesReport.e18(victimShares),
                " attackerPreviewRedeem=",
                FixturesReport.e18(attackerRedeem),
                " victimPreviewRedeem=",
                FixturesReport.e18(victimRedeem)
            ),
            "inflation muted (numbers only; not a safety claim)",
            "none named (offset reduced the rounding wipeout in this fixture)"
        );
    }

    function _runInflation(ERC4626 vault)
        internal
        returns (uint256 attackerShares, uint256 victimShares, uint256 attackerRedeem, uint256 victimRedeem)
    {
        vm.startPrank(attacker);
        asset.approve(address(vault), type(uint256).max);
        attackerShares = vault.deposit(1, attacker);
        asset.transfer(address(vault), DONATION);
        vm.stopPrank();

        vm.startPrank(victim);
        asset.approve(address(vault), type(uint256).max);
        victimShares = vault.deposit(VICTIM_DEPOSIT, victim);
        vm.stopPrank();

        attackerRedeem = vault.previewRedeem(attackerShares);
        victimRedeem = victimShares == 0 ? 0 : vault.previewRedeem(victimShares);
    }
}
