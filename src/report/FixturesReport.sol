// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Vm} from "forge-std/Vm.sol";

/// @notice Machine appendix. Humans read reports/test-vaults.md.
library FixturesReport {
    address private constant VM_ADDR = address(uint160(uint256(keccak256("hevm cheat code"))));

    string internal constant PATH = "reports/_generated.md";

    function ensureHeader() internal {
        Vm vm = Vm(VM_ADDR);
        try vm.readFile(PATH) returns (string memory existing) {
            if (bytes(existing).length > 0) return;
        } catch {}
        vm.writeFile(
            PATH,
            string.concat(
                "# Machine appendix (not the human report)\n\n",
                "Read [test-vaults.md](test-vaults.md) instead.\n\n",
                "| vault | case | ran | facts | spec | who is hurt |\n",
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
