// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Vm} from "forge-std/Vm.sol";

/// @notice Writer for reports/live.md (vault test report, not an audit).
library LiveReport {
    address private constant VM_ADDR = address(uint160(uint256(keccak256("hevm cheat code"))));

    string internal constant PATH = "reports/live.md";

    function init(uint256 pinnedBlock) internal {
        Vm vm = Vm(VM_ADDR);
        vm.writeFile(
            PATH,
            string.concat(
                "# ERC-4626 vault test report (live mainnet fork)\n\n",
                "This is a **vault test report**, not an audit.\n",
                "Judgment is **who is hurt**. If no victim is named by the numbers, write `none named`.\n\n",
                "- Pinned block: `",
                vm.toString(pinnedBlock),
                "`\n",
                "- RPC: public Alchemy endpoint (may throttle / 429)\n",
                "- Fork: single `createSelectFork` for the whole live run\n\n",
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

    /// @dev Format raw token amounts with a decimals hint (e.g. "1000000(6dec)").
    function qty(uint256 x, uint8 decimals) internal pure returns (string memory) {
        Vm vm = Vm(VM_ADDR);
        if (x == 0) return "0";
        uint256 unit = 10 ** uint256(decimals);
        if (unit > 0 && x % unit == 0) {
            return string.concat(vm.toString(x / unit), "e", vm.toString(uint256(decimals)));
        }
        if (unit > 0 && x > unit) {
            return string.concat(vm.toString(x / unit), "e", vm.toString(uint256(decimals)), "+", vm.toString(x % unit));
        }
        return string.concat(vm.toString(x), "(", vm.toString(uint256(decimals)), "dec)");
    }

    function u(uint256 x) internal pure returns (string memory) {
        Vm vm = Vm(VM_ADDR);
        return vm.toString(x);
    }
}
