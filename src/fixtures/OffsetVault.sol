// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice OZ ERC-4626 with `_decimalsOffset() == 3` (virtual shares mute first-depositor inflation).
contract OffsetVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Offset Vault", "oVAULT") ERC4626(asset_) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 3;
    }
}
