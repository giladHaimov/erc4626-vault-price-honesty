// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice FailedPreviewLieVault
///
/// What it is: OpenZeppelin ERC-4626 whose preview* helpers lie vs convertTo*.
/// Why Failed*: we expect the preview-vs-actual case to fail.
///
/// How it fails:
///   previewDeposit / previewRedeem overstate shares / assets.
///   previewMint / previewWithdraw understate cost.
///   OpenZeppelin deposit() calls previewDeposit(), so the lie is minted.
///
/// Bad outcome: unfair share mint. Existing holders are diluted. Anyone who trusts
/// convertTo* as "what deposit will mint" is wrong.
contract FailedPreviewLieVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Failed Preview Lie Vault", "failPREV") ERC4626(asset_) {}

    function previewDeposit(uint256 assets) public view override returns (uint256) {
        uint256 honest = convertToShares(assets);
        return honest + (honest / 10) + 1;
    }

    function previewMint(uint256 shares) public view override returns (uint256) {
        uint256 honest = convertToAssets(shares);
        uint256 cut = honest / 10;
        if (cut + 1 >= honest) return 0;
        return honest - cut - 1;
    }

    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        uint256 honest = convertToShares(assets);
        uint256 cut = honest / 10;
        if (cut + 1 >= honest) return 0;
        return honest - cut - 1;
    }

    function previewRedeem(uint256 shares) public view override returns (uint256) {
        uint256 honest = convertToAssets(shares);
        return honest + (honest / 10) + 1;
    }
}
