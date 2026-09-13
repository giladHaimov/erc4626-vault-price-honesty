# Method

This is how the report is produced. It is not an audit procedure.

## Order of cases

1. **Preview vs actual** — EIP-4626 is directional, not `==`.
2. **Leftover empty** — `totalSupply == 0` with ERC-20 still on the vault. Live: N/A (we do not storage-zero a pot).
3. **Gift vs deposit** — official `deposit`, then a plain `transfer` of the same asset. No source required.
4. **First-depositor inflation** — empty donation. Live: N/A unless the vault is actually empty (none on this allowlist).
5. **Helper gap** — `totalAssets` vs `asset.balanceOf(vault)`. A static mismatch is architecture. A gap that opens and closes is the risk we would measure across pins. One pin: N/A architecture + numbers.

## Fixture vs live

| | Fixtures | Live fork |
|---|---|---|
| Purpose | Prove the tool (planted faults + clean vault) | Study real pots |
| Preview | All four functions | Deposit; redeem if not gated |
| Leftover / first depositor | Exercised | N/A + why |
| RPC | None | `MAINNET_RPC_URL`, one pinned block |

## Who is hurt

If the numbers do not name a victim, the cell is `none named`. I do not invent one. A gift that raises price hurts later depositors and helps existing LPs — that is not theft. I do not call leftover-empty a cheat.

## What we will not do

- Call the report an audit, exhaustive, or the best route
- Headline “I fixed OpenZeppelin”
- Storage-zero a live vault
- Claim a fee/oracle bug from a price jump without a fee path
