// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {MockAsset} from "../src/mock/MockAsset.sol";
import {FailedFirstDepositorVault} from "../src/test-vaults/FailedFirstDepositorVault.sol";
import {CorrectOffsetVault} from "../src/test-vaults/CorrectOffsetVault.sol";

/// @notice Empty-pot unfairness fuzz (first-depositor + leftover-empty).
/// Part of share-price honesty. Not a generic vault fuzzer.
///
/// OZ offset 0: shares = assets * (supply + 1) / (totalAssets + 1).
/// After a 1-wei first deposit + gift `donation`, victim deposit `v` mints
/// floor(2*v / (donation + 2)) shares. Zero shares when 2*v < donation + 2.
///
/// After leftover `L` and no real shares, next deposit `b` mints floor(b / (L + 1)).
/// Zero shares when b < L + 1.
contract EmptyPotUnfairnessFuzz is Test {
    MockAsset internal asset;
    address internal attacker = makeAddr("attacker");
    address internal victim = makeAddr("victim");
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal donor = makeAddr("donor");

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
    }

    /// @dev FailedFirstDepositorVault: when the gift dominates, victim gets 0 shares.
    function testFuzz_firstDepositor_wipeoutWhenGiftDominates(uint256 donation, uint256 victimDeposit) public {
        donation = bound(donation, 1e18, 1e22);
        victimDeposit = bound(victimDeposit, 1, 1e20);
        vm.assume(2 * victimDeposit < donation + 2);

        FailedFirstDepositorVault vault = new FailedFirstDepositorVault(IERC20(address(asset)));
        uint256 victimShares = _firstDepositor(vault, donation, victimDeposit);
        assertEq(victimShares, 0, "empty-pot unfairness: victim minted 0 shares");
    }

    /// @dev Same vault: when the deposit is large vs the gift, victim gets shares.
    function testFuzz_firstDepositor_sharesWhenDepositDominates(uint256 donation, uint256 victimDeposit) public {
        donation = bound(donation, 1, 1e18);
        victimDeposit = bound(victimDeposit, donation + 2, 1e20);

        FailedFirstDepositorVault vault = new FailedFirstDepositorVault(IERC20(address(asset)));
        uint256 victimShares = _firstDepositor(vault, donation, victimDeposit);
        assertGt(victimShares, 0, "victim should mint shares when deposit dominates gift");
    }

    /// @dev Offset 3 does not mute every pair. It does mute the band around the
    /// unit test (50e18 deposit vs 10_000e18 gift). Fuzz that band.
    function testFuzz_offset_mutesWipeoutInUnitBand(uint256 donation, uint256 victimDeposit) public {
        donation = bound(donation, 1_000e18, 20_000e18);
        victimDeposit = bound(victimDeposit, 20e18, 100e18);
        vm.assume(2 * victimDeposit < donation + 2);

        FailedFirstDepositorVault plain = new FailedFirstDepositorVault(IERC20(address(asset)));
        assertEq(_firstDepositor(plain, donation, victimDeposit), 0, "offset 0 still wipes in this band");

        CorrectOffsetVault offset = new CorrectOffsetVault(IERC20(address(asset)));
        assertGt(_firstDepositor(offset, donation, victimDeposit), 0, "offset 3 mints shares in this band");
    }

    /// @dev Same inputs: offset 3 never mints fewer shares than offset 0.
    function testFuzz_offset_atLeastAsManyShares(uint256 donation, uint256 victimDeposit) public {
        donation = bound(donation, 1e18, 1e22);
        victimDeposit = bound(victimDeposit, 1, 1e20);

        FailedFirstDepositorVault plain = new FailedFirstDepositorVault(IERC20(address(asset)));
        uint256 plainShares = _firstDepositor(plain, donation, victimDeposit);

        CorrectOffsetVault offset = new CorrectOffsetVault(IERC20(address(asset)));
        uint256 offsetShares = _firstDepositor(offset, donation, victimDeposit);
        assertGe(offsetShares, plainShares, "offset 3 should not mint fewer shares than offset 0");
    }

    /// @dev Leftover tokens, no real shares: next depositor gets 0 shares if deposit < leftover+1.
    function testFuzz_leftover_nextDepositorWiped(uint256 leftover, uint256 bobDeposit) public {
        leftover = bound(leftover, 1e18, 1e22);
        bobDeposit = bound(bobDeposit, 1, leftover); // bobDeposit < leftover+1
        vm.assume(bobDeposit < leftover + 1);

        FailedFirstDepositorVault vault = _emptyWithLeftover(leftover);
        uint256 bobShares = _bobDeposit(vault, bobDeposit);
        assertEq(bobShares, 0, "leftover empty: next depositor minted 0 shares");
    }

    /// @dev Leftover smaller than next deposit: next depositor gets shares (and may receive leftover).
    function testFuzz_leftover_nextDepositorGetsShares(uint256 leftover, uint256 bobDeposit) public {
        leftover = bound(leftover, 1, 1e18);
        bobDeposit = bound(bobDeposit, leftover + 1, 1e20);

        FailedFirstDepositorVault vault = _emptyWithLeftover(leftover);
        uint256 bobShares = _bobDeposit(vault, bobDeposit);
        assertGt(bobShares, 0, "leftover empty: large next deposit still mints shares");
        assertGt(vault.previewRedeem(bobShares), 0, "those shares redeem something");
    }

    function _firstDepositor(ERC4626 vault, uint256 donation, uint256 victimDeposit)
        internal
        returns (uint256 victimShares)
    {
        asset.mint(attacker, donation + 1);
        asset.mint(victim, victimDeposit);

        vm.startPrank(attacker);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(1, attacker);
        asset.transfer(address(vault), donation);
        vm.stopPrank();

        vm.startPrank(victim);
        asset.approve(address(vault), type(uint256).max);
        victimShares = vault.deposit(victimDeposit, victim);
        vm.stopPrank();
    }

    function _emptyWithLeftover(uint256 leftover) internal returns (FailedFirstDepositorVault vault) {
        vault = new FailedFirstDepositorVault(IERC20(address(asset)));
        uint256 seed = 1_000e18;
        asset.mint(alice, seed);
        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        uint256 shares = vault.deposit(seed, alice);
        vault.redeem(shares, alice, alice);
        vm.stopPrank();
        assertEq(vault.totalSupply(), 0, "shares gone");

        asset.mint(donor, leftover);
        vm.prank(donor);
        asset.transfer(address(vault), leftover);
        // OZ may leave 1 wei of rounding dust after the last redeem.
        assertGe(asset.balanceOf(address(vault)), leftover);
    }

    function _bobDeposit(FailedFirstDepositorVault vault, uint256 bobDeposit) internal returns (uint256 bobShares) {
        asset.mint(bob, bobDeposit);
        vm.startPrank(bob);
        asset.approve(address(vault), type(uint256).max);
        bobShares = vault.deposit(bobDeposit, bob);
        vm.stopPrank();
    }
}
