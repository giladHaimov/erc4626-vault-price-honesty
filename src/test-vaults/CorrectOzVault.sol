// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice Plain OpenZeppelin ERC-4626. The clean control.
contract CorrectOzVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Correct OZ Vault", "cOZ") ERC4626(asset_) {}
}
