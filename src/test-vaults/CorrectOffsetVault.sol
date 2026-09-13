// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @notice OpenZeppelin 4626 with virtual shares (offset 3). We expect first-depositor wipeout muted.
contract CorrectOffsetVault is ERC4626 {
    constructor(IERC20 asset_) ERC20("Correct Offset Vault", "cOFF") ERC4626(asset_) {}

    function _decimalsOffset() internal pure override returns (uint8) {
        return 3;
    }
}
