// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MockAsset} from "../src/mock/MockAsset.sol";
import {FailedFirstDepositorVault} from "../src/test-vaults/FailedFirstDepositorVault.sol";
import {TestVaultReport} from "../src/report/TestVaultReport.sol";

/// @notice Alice deposits, redeems ALL, then tokens are transferred in while supply==0; Bob deposits.
/// Do NOT fail this vault for leftover. Report facts. Report facts. Who-is-hurt: usually none named.
/// @dev Do not report convertToAssets(1e18) when supply is 1 share — that number is meaningless.
contract LeftoverEmptyTest is Test {
    MockAsset internal asset;
    FailedFirstDepositorVault internal vault;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal donor = makeAddr("donor");

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
        vault = new FailedFirstDepositorVault(IERC20(address(asset)));
        asset.mint(alice, 10_000e18);
        asset.mint(bob, 10_000e18);
        asset.mint(donor, 5_000e18);
    }

    function test_FailedFirstDepositor_leftoverEmpty_facts() public {
        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        uint256 aliceShares = vault.deposit(1_000e18, alice);
        uint256 aliceRedeemAssets = vault.redeem(aliceShares, alice, alice);
        vm.stopPrank();

        assertEq(vault.totalSupply(), 0, "vault empty of shares");

        uint256 gift = 500e18;
        vm.prank(donor);
        asset.transfer(address(vault), gift);

        uint256 leftoverAtEmpty = asset.balanceOf(address(vault));
        assertEq(vault.totalSupply(), 0);
        assertEq(leftoverAtEmpty, gift);

        vm.startPrank(bob);
        asset.approve(address(vault), type(uint256).max);
        uint256 bobAssets = 1_000e18;
        uint256 bobShares = vault.deposit(bobAssets, bob);
        uint256 bobRedeemValue = vault.previewRedeem(bobShares);
        vm.stopPrank();

        string memory facts = string.concat(
            "aliceShares=",
            TestVaultReport.e18(aliceShares),
            " aliceRedeem=",
            TestVaultReport.e18(aliceRedeemAssets),
            " leftoverAtEmpty=",
            TestVaultReport.e18(leftoverAtEmpty),
            " bobShares=",
            vm.toString(bobShares),
            " bobDeposit=",
            TestVaultReport.e18(bobAssets),
            " bobPreviewRedeem=",
            TestVaultReport.e18(bobRedeemValue)
        );

        TestVaultReport.row(
            "FailedFirstDepositorVault",
            "LeftoverEmpty",
            "ran",
            facts,
            "facts only (no fail for leftover)",
            "none named (next depositor may receive leftover)"
        );
    }
}
