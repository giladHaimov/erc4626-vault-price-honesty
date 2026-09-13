// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice OZ ERC-4626 with a cached NAV. Gifts do not move totalAssets until poke().
contract StaleNavVault is ERC4626 {
    uint256 public cachedAssets;

    constructor(IERC20 asset_) ERC20("Stale NAV Vault", "staleVAULT") ERC4626(asset_) {}

    function totalAssets() public view override returns (uint256) {
        return cachedAssets;
    }

    function poke() external {
        cachedAssets = IERC20(asset()).balanceOf(address(this));
    }

    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal override {
        super._deposit(caller, receiver, assets, shares);
        cachedAssets += assets;
    }

    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal override {
        super._withdraw(caller, receiver, owner, assets, shares);
        cachedAssets -= assets;
    }
}
