# Method

This is how the report is produced. It is not an audit procedure.

## Test vaults vs live snapshot

| | Test vaults | Live snapshot |
|---|---|---|
| What | Local demo vaults we deploy in Foundry | Real vaults already on Ethereum |
| Why | Prove the suite on a known-good and known-bad vault | Measure real pots we cannot honestly fake |
| Cost | None | RPC read. No mainnet gas. |
| Preview | All four functions | Deposit; redeem if not gated |
| Leftover / first depositor | Exercised | N/A — we do not empty a live pot |

A snapshot is not “running tests on mainnet.” Foundry copies one **pinned** block (`createSelectFork(rpc, 25967333)`). Forking `latest` and then writing down `block.number` is not a pin.

## Order of cases

1. **Preview vs actual** — EIP-4626 is directional, not `==`.
2. **Leftover empty** — `totalSupply == 0` with ERC-20 still on the vault. Live: N/A.
3. **Gift vs deposit** — official `deposit`, then a plain `transfer` of the same asset.
4. **First-depositor inflation** — empty donation. Live: N/A unless the vault is actually empty.
5. **Helper gap** — `totalAssets` vs `asset.balanceOf(vault)`. A static mismatch is architecture.

## When we mark unfair mint

We mark it when a victim is named by the numbers: first-depositor wipeout (0 shares) and the preview lie (extra shares minted). We do not auto-stamp leftover-empty as unfair — the next depositor can still take the leftover. That is a product choice, not a tech limit.

If the numbers do not name a victim, the cell is `none named`.
