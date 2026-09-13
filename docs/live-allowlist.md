# Live vault allowlist (Phase 2 stub)

Pinned-block fork targets. Do not invent addresses — fill only when verified.

| address | name | pinned block | notes |
|---|---|---|---|
| `0x83F20F44975D03b1b09e64809B757c47f942BEeA` | sDAI (Spark / Maker) | TBD | Well-known ERC-4626; re-verify on-chain before P2 |
| TBD | Yearn V3 vault (pick one) | TBD | Confirm 4626 + address on etherscan |
| TBD | Morpho vault (pick one) | TBD | Confirm 4626 + address |
| TBD | Euler vault (pick one) | TBD | Confirm 4626 + address |
| TBD | TBD | TBD | Placeholder |

`LiveFork.t.sol` skips until `MAINNET_RPC_URL` is set and this table is filled.
