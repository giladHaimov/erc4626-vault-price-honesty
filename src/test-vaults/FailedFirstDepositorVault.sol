// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice FailedFirstDepositorVault
///
/// What it is: a plain OpenZeppelin ERC-4626. No extra code. Offset 0.
/// Why Failed*: we expect the first-depositor case to fail.
///
/// How it fails:
///   1. Vault is empty.
///   2. Attacker deposits 1 wei and then gifts a large pile of tokens.
///   3. Victim deposits a normal amount.
///   4. Victim gets 0 shares. Attacker can redeem almost the whole pot.
///
/// Bad outcome: unfair share mint. Victim paid and got nothing.
///
/// Other cases: preview still matches. Gifts count (price goes up). Leftover-empty is facts only.
contract FailedFirstDepositorVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Failed First Depositor Vault", "failFD") ERC4626(asset_) {}
}
