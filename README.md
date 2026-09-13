# ERC-4626 vault test report (Foundry)

I measure 4626 pots. I don’t sell a cure.

**This is not an audit.** It is a Foundry suite that writes a **vault test report**. It is not a patched vault and not a claim that OpenZeppelin leftover-empty cheats depositors. After the last share is gone you can get fewer new shares and still redeem about the same tokens. A senior asks who lost money. Often nobody did.

What still bites teams is composability: `preview*` vs the real call, a share price that jumps, a fee or oracle that treats that jump as yield.

## Run

```bash
cp .env.example .env   # Phase 2 only; leave empty for fixtures
rm -f reports/fixtures.md
forge test --jobs 1 -vv
```

`--jobs 1` so report rows do not interleave. No RPC required for Phase 1. Output: `reports/fixtures.md`.

## What a reviewer should open

1. This README
2. `docs/PRD.md` — cases, non-goals, who-is-hurt
3. `test/` — one file per case
4. `reports/fixtures.md` — last local run

Judgment column is **who is hurt**, not vulnerable/safe. If the numbers do not name a victim, the cell is `none named`.

## Fixtures (Phase 1)

| Fixture | What it is for |
|---|---|
| `BaselineVault` | Boring OZ ERC-4626. Preview should hold. Gifts count. Leftover-empty and first-depositor are facts. |
| `OffsetVault` | Virtual offset. First-depositor inflation muted (not a safety claim). |
| `PreviewLiarVault` | `preview*` disagrees with `convertTo*`. OZ mutators follow `preview*`, so deposit==preview still holds. |
| `StaleNavVault` | Cached NAV. Gifts ignored until `poke()`. |

## Cases

1. Preview vs actual (directional spec, all four functions)
2. Leftover empty (shares = 0, tokens remain)
3. Gift vs official `deposit`
4. First-depositor inflation
5. Helper gap (only if decodable; else N/A)

## Phase 2 (live fork)

Allowlisted mainnet ERC-4626s at one pinned block via `vm.createSelectFork`. Writes `reports/live.md`. Needs `MAINNET_RPC_URL` (see `.env.example`). Allowlist: `docs/live-allowlist.md`.

```bash
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path 'test/Live*.t.sol' -vv
```

Without `MAINNET_RPC_URL`, live tests skip and fixture tests still pass.

## License

MIT
