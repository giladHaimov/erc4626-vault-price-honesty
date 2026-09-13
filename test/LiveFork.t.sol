// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

/// @notice Phase 2 placeholder. Skips without MAINNET_RPC_URL (and always skips with P2 reason if env empty).
contract LiveForkTest is Test {
    function test_liveFork_skippedUntilP2() public {
        string memory rpc = vm.envOr("MAINNET_RPC_URL", string(""));
        if (bytes(rpc).length == 0) {
            vm.skip(true, "P2: needs MAINNET_RPC_URL + allowlist");
        }
        // Even if RPC is set, Phase 1 has no live addresses wired yet.
        vm.skip(true, "P2: needs MAINNET_RPC_URL + allowlist");
    }
}
