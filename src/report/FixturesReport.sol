// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Vm} from "forge-std/Vm.sol";

/// @notice Shared writer for reports/fixtures.md (vault test report, not an audit).
library FixturesReport {
    address private constant VM_ADDR = address(uint160(uint256(keccak256("hevm cheat code"))));

    string internal constant PATH = "reports/fixtures.md";

    function ensureHeader() internal {
        Vm vm = Vm(VM_ADDR);
        try vm.readFile(PATH) returns (string memory existing) {
            if (bytes(existing).length > 0) return;
        } catch {}
        vm.writeFile(
            PATH,
            string.concat(
                "# ERC-4626 vault test report (local fixtures)\n\n",
                "This is a **vault test report**, not an audit.\n",
                "Judgment is **who is hurt**. If no victim is named by the numbers, write `none named`.\n\n",
                "| subject | case | ran/N/A | facts | spec | who is hurt |\n",
                "|---|---|---|---|---|---|\n"
            )
        );
    }

    function row(
        string memory subject,
        string memory caseName,
        string memory ran,
        string memory facts,
        string memory spec,
        string memory whoIsHurt
    ) internal {
        ensureHeader();
        Vm vm = Vm(VM_ADDR);
        vm.writeLine(
            PATH,
            string.concat(
                "| ",
                subject,
                " | ",
                caseName,
                " | ",
                ran,
                " | ",
                facts,
                " | ",
                spec,
                " | ",
                whoIsHurt,
                " |"
            )
        );
    }

    /// @dev 1000e18 -> "1000e18"; 1 -> "1"; leftover dust -> "750e18+1"
    function e18(uint256 x) internal pure returns (string memory) {
        Vm vm = Vm(VM_ADDR);
        if (x == 0) return "0";
        if (x % 1e18 == 0) return string.concat(vm.toString(x / 1e18), "e18");
        if (x > 1e18) {
            return string.concat(vm.toString(x / 1e18), "e18+", vm.toString(x % 1e18));
        }
        return vm.toString(x);
    }
}
