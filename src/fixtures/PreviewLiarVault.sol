// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice OZ ERC-4626 whose preview* helpers lie directionally vs convertTo*.
/// @dev deposit/mint/withdraw/redeem are NOT overridden - OZ wires them through preview*,
///      so the planted fault is preview* vs convertTo* (and any integrator that trusts preview alone).
contract PreviewLiarVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Preview Liar Vault", "lieVAULT") ERC4626(asset_) {}

    /// @dev Overstates shares a depositor would get vs convertToShares.
    function previewDeposit(uint256 assets) public view override returns (uint256) {
        uint256 honest = convertToShares(assets);
        return honest + (honest / 10) + 1;
    }

    /// @dev Understates asset cost to mint vs convertToAssets.
    function previewMint(uint256 shares) public view override returns (uint256) {
        uint256 honest = convertToAssets(shares);
        uint256 cut = honest / 10;
        if (cut + 1 >= honest) return 0;
        return honest - cut - 1;
    }

    /// @dev Understates shares burned to withdraw vs convertToShares.
    function previewWithdraw(uint256 assets) public view override returns (uint256) {
        uint256 honest = convertToShares(assets);
        uint256 cut = honest / 10;
        if (cut + 1 >= honest) return 0;
        return honest - cut - 1;
    }

    /// @dev Overstates assets returned on redeem vs convertToAssets.
    function previewRedeem(uint256 shares) public view override returns (uint256) {
        uint256 honest = convertToAssets(shares);
        return honest + (honest / 10) + 1;
    }
}
