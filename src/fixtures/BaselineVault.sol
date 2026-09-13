// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Boring OZ ERC-4626 with default `_decimalsOffset() == 0`.
contract BaselineVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Baseline Vault", "bVAULT") ERC4626(asset_) {}
}
