# PRD — ERC-4626 vault test report (Foundry)

Status: Phase 1 (local fixtures). Not an audit. Not a patched vault.

## Goal

Measure ERC-4626 pots and write a **vault test report**. Do not sell a cure. Do not claim OpenZeppelin leftover-empty is a cheat. After the last share is gone, fewer new shares can still redeem about the same tokens. A senior asks who lost money. Often nobody did.

Tagline: *I measure 4626 pots. I don’t sell a cure. I do say who gets hurt when I can prove it.*

## Non-goals (do not add)

- “I fixed OZ” / “unfair shares” / “depositor was cheated” as the headline
- Adapter / harvest / helper-lie / DAO / AI
- Calling the report an audit, exhaustive, or the best route
- Storage-zeroing a live pot and calling that “protocol empty”
- Marking a vault vulnerable/safe instead of **who is hurt**
- Inventing a victim when the numbers do not name one
- Claiming a fee/oracle bug from a price jump alone (only if a real fee path is shown)

## Product

1. **Local fixtures (required, this phase).** One boring-correct vault + planted-fault vaults. This is the proof the tool works. Forks are the demo.
2. **Live forks (later).** 10–15 mainnet vaults at pinned blocks. Mocks only if `deposit` is gated. Each case: ran / N/A + why.
3. **Report.** Markdown table. Facts first. One judgment column: who is hurt.

## Cases (order is the point)

1. **Preview vs actual** — spec is directional, not `==`.
   - `deposit` / `redeem`: actual **≥** preview
   - `mint` / `withdraw`: actual cost **≤** preview
   - Check all four plus balances in the same flow.
2. **Leftover empty** — `totalSupply == 0`, ERC-20 still on the vault. Report share *count*, redeem *value*, whether price jumped. Do not call this a theft.
3. **Gift vs deposit** — call `deposit()`, then `transfer` the same token to the vault. If `totalAssets` or price moves on the transfer, they count gifts. No source required.
4. **First-depositor inflation** — empty donation. Included so it is not forgotten.
5. **Helper gap** — only if we can decode the position. `totalAssets ≠ balanceOf(vault)` is usually architecture. A gap that opens and closes over time is the measurable risk. If we cannot decode: **not enough data**, not “helper lie.”

## Fixtures (Phase 1)

| Fixture | Role |
|---|---|
| `BaselineVault` | Boring OZ ERC-4626, offset 0. Industry default. Preview should pass. Gift counted. Leftover-empty and first-depositor are *measurable facts*, not “OZ is broken.” |
| `OffsetVault` | Same + `_decimalsOffset() == 3`. First-depositor inflation should be muted. |
| `PreviewLiarVault` | `previewDeposit` (and siblings) optimistic vs the real mint. Must fail case 1. |
| `StaleNavVault` | Cached `totalAssets`; gifts do not move NAV until `poke()`. Gift case: ignored. Helper-gap: `totalAssets ≠ balance`. |

Asset: a mintable mock ERC-20. No mainnet RPC in Phase 1.

## Report columns

`subject | case | ran/N/A | facts (before/after) | spec | who is hurt`

If who-is-hurt is unknown, write `none named` — do not invent.

## Phases

- **P1** — this repo boots: Foundry, fixtures, local tests, `reports/fixtures.md` written by tests. `forge test` green without RPC.
- **P2** — live-fork harness + allowlist of 10–15 addresses + pinned blocks + per-case N/A reasons. Needs `MAINNET_RPC_URL`.
- **P3** — published report for those vaults. GitHub face / pins are packaging, not this repo.

## Done for P1

- `forge test` passes on a clean machine with Foundry, no RPC.
- Preview liar fails case 1; baseline passes case 1.
- Leftover, gift, first-depositor emit numbers + who-is-hurt, not pass/fail-as-audit.
- README never says audit, never says we found an OZ bug.
