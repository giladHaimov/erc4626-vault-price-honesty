// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {MockAsset} from "../src/fixtures/MockAsset.sol";
import {BaselineVault} from "../src/fixtures/BaselineVault.sol";
import {OffsetVault} from "../src/fixtures/OffsetVault.sol";
import {PreviewLiarVault} from "../src/fixtures/PreviewLiarVault.sol";
import {FixturesReport} from "../src/report/FixturesReport.sol";

/// @notice EIP-4626 directional preview vs actual (and preview vs convertTo* for the planted liar).
/// deposit/redeem: actual >= preview; mint/withdraw: actual cost/burn <= preview.
contract PreviewVsActualTest is Test {
    MockAsset internal asset;
    address internal alice = makeAddr("alice");

    uint256 internal lastDepActual;
    uint256 internal lastDepPreview;
    uint256 internal lastMintActual;
    uint256 internal lastMintPreview;
    uint256 internal lastWdActual;
    uint256 internal lastWdPreview;
    uint256 internal lastRedActual;
    uint256 internal lastRedPreview;

    function setUp() public {
        asset = new MockAsset("Mock USD", "mUSD");
        asset.mint(alice, 1_000_000e18);
    }

    function test_Baseline_previewVsActual_passes() public {
        BaselineVault vault = new BaselineVault(IERC20(address(asset)));
        _runDirectional(vault);
        _reportPass("BaselineVault");
    }

    function test_Offset_previewVsActual_passes() public {
        OffsetVault vault = new OffsetVault(IERC20(address(asset)));
        _runDirectional(vault);
        _reportPass("OffsetVault");
    }

    function test_PreviewLiar_caught_vs_convertTo() public {
        PreviewLiarVault vault = new PreviewLiarVault(IERC20(address(asset)));

        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);
        vault.deposit(10_000e18, alice);
        vm.stopPrank();

        uint256 assets = 1_000e18;
        uint256 shares = 100e18;

        assertGt(vault.previewDeposit(assets), vault.convertToShares(assets), "liar overstates deposit");
        assertLt(vault.previewMint(shares), vault.convertToAssets(shares), "liar understates mint");
        assertLt(vault.previewWithdraw(assets), vault.convertToShares(assets), "liar understates withdraw");
        assertGt(vault.previewRedeem(shares), vault.convertToAssets(shares), "liar overstates redeem");

        uint256 pDep = vault.previewDeposit(assets);
        vm.prank(alice);
        uint256 minted = vault.deposit(assets, alice);
        assertEq(minted, pDep, "OZ deposit follows previewDeposit");

        FixturesReport.row(
            "PreviewLiarVault",
            "PreviewVsActual",
            "ran",
            string.concat(
                "previewDeposit>",
                "convertToShares; previewMint<",
                "convertToAssets; previewWithdraw<",
                "convertToShares; previewRedeem>",
                "convertToAssets; OZ deposit minted==lied preview=",
                FixturesReport.e18(minted)
            ),
            "FAIL (preview vs convertTo*; planted)",
            "existing LPs (OZ deposit mints the lied preview); integrators who treat convertTo* as the mint"
        );
    }

    function _runDirectional(ERC4626 vault) internal {
        vm.startPrank(alice);
        asset.approve(address(vault), type(uint256).max);

        lastDepPreview = vault.previewDeposit(1_000e18);
        uint256 before = vault.balanceOf(alice);
        lastDepActual = vault.deposit(1_000e18, alice);
        assertEq(lastDepActual, vault.balanceOf(alice) - before);
        assertGe(lastDepActual, lastDepPreview, "deposit: actual >= preview");

        lastMintPreview = vault.previewMint(50e18);
        uint256 assetsBefore = asset.balanceOf(alice);
        lastMintActual = vault.mint(50e18, alice);
        assertEq(lastMintActual, assetsBefore - asset.balanceOf(alice));
        assertLe(lastMintActual, lastMintPreview, "mint: actual cost <= preview");

        lastWdPreview = vault.previewWithdraw(100e18);
        uint256 sharesBefore = vault.balanceOf(alice);
        lastWdActual = vault.withdraw(100e18, alice, alice);
        assertEq(lastWdActual, sharesBefore - vault.balanceOf(alice));
        assertLe(lastWdActual, lastWdPreview, "withdraw: actual burn <= preview");

        lastRedPreview = vault.previewRedeem(20e18);
        assetsBefore = asset.balanceOf(alice);
        lastRedActual = vault.redeem(20e18, alice, alice);
        assertEq(lastRedActual, asset.balanceOf(alice) - assetsBefore);
        assertGe(lastRedActual, lastRedPreview, "redeem: actual >= preview");

        vm.stopPrank();
    }

    function _reportPass(string memory subject) internal {
        FixturesReport.row(
            subject,
            "PreviewVsActual",
            "ran",
            string.concat(
                "dep ",
                FixturesReport.e18(lastDepActual),
                "/",
                FixturesReport.e18(lastDepPreview),
                "; mint ",
                FixturesReport.e18(lastMintActual),
                "/",
                FixturesReport.e18(lastMintPreview),
                "; wd ",
                FixturesReport.e18(lastWdActual),
                "/",
                FixturesReport.e18(lastWdPreview),
                "; red ",
                FixturesReport.e18(lastRedActual),
                "/",
                FixturesReport.e18(lastRedPreview)
            ),
            "PASS (directional)",
            "none named"
        );
    }
}
