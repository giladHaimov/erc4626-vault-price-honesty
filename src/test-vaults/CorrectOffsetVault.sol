// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice CorrectOffsetVault
///
/// What it is: OpenZeppelin ERC-4626 plus virtual shares (`_decimalsOffset() == 3`).
/// Why Correct*: we expect the cases we run to pass — first-depositor wipeout is muted.
///
/// What would count as a fail (we do not expect this):
///   same empty-pot attack as FailedFirstDepositorVault, victim gets 0 shares.
///
/// What we see instead: victim gets shares and can redeem a real amount.
/// Preview matches. Not a claim that the vault is "safe" in every attack, only that this wipeout is muted.
contract CorrectOffsetVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Correct Offset Vault", "cOFF") ERC4626(asset_) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 3;
    }
}
