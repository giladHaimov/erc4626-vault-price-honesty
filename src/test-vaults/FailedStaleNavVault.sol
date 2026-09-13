// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice FailedStaleNavVault
///
/// What it is: OpenZeppelin ERC-4626 with a cached totalAssets (NAV).
/// Why Failed*: we expect the gift case (and helper-gap case) to fail until poke().
///
/// How it fails:
///   deposit/withdraw update the cache. A plain token gift does not.
///   totalAssets stays stale. Share price does not move.
///   poke() copies the real token balance into the cache.
///
/// Bad outcome: anyone who reads totalAssets / share price before poke sees the wrong number.
contract FailedStaleNavVault is ERC4626 {
    uint256 public cachedAssets;

    constructor(IERC20 asset_) ERC20("Failed Stale NAV Vault", "failNAV") ERC4626(asset_) {}

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
