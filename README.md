# ERC-4626 vault test report

**I measure 4626 pots. I don’t sell a cure.**

[![ci](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml/badge.svg)](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml)

A Foundry suite that forks live ERC-4626 vaults at a **pinned block** and writes a **vault test report**. Judgment is **who is hurt**, not vulnerable/safe.

This is **not an audit**, not a patched vault, and not a claim that OpenZeppelin leftover-empty cheats depositors. After the last share is gone you can get fewer new shares and still redeem about the same tokens. A senior asks who lost money. Often nobody did.

What still bites teams is composability: `preview*` vs the real call, a share price that jumps, a fee or oracle that treats that jump as yield.

## Last live run — block `25967333`

Public Alchemy fork. **11 vaults completed cases.** Four others have code on the fork but `asset()` empty-reverts (proxy/impl the public RPC does not follow). Same addresses answer `cast call`. That is a fork-RPC limit, not “not a 4626.”

| vault | preview vs deposit | gifts | leftover / first depositor | helper gap | who is hurt |
|---|---|---|---|---|---|
| sDAI (Spark) | PASS | not counted | N/A (live pot) | architecture (DSR pot) | none named |
| sUSDS (Spark) | PASS | not counted | N/A | architecture | none named |
| **sUSDe (Ethena)** | PASS; redeem cooldown | **counted** | N/A | architecture | later depositors pay more; existing LPs gain (not theft) |
| yvUSDC-1 (Yearn V3) | PASS | not counted | N/A | architecture (strategies) | none named |
| yvWETH-1 (Yearn V3) | PASS | not counted | N/A | architecture | none named |
| yvDAI-1 (Yearn V3) | PASS | not counted | N/A | architecture | none named |
| yvUSD (Yearn V3) | N/A gated | not counted (deposit gated) | N/A | architecture | none named |
| yvUSDS-1 (Yearn V3) | PASS | not counted | N/A | architecture | none named |
| Steakhouse USDC (Morpho) | PASS | not counted | N/A | architecture (markets) | none named |
| Gauntlet USDC Core (Morpho) | PASS | not counted | N/A | architecture (idle 0) | none named |
| sfrxETH | PASS | not counted | N/A | architecture | none named |
| sUSDC / Gauntlet Prime / 2 Euler EVK / yvUSDT | — | — | — | — | public-fork `asset()`/run revert; `cast call` works |

Full numbers: [`reports/live.md`](reports/live.md). How we measure: [`docs/METHOD.md`](docs/METHOD.md). Allowlist: [`docs/live-allowlist.md`](docs/live-allowlist.md).

A price jump alone is not a fee bug. I only name a fee/oracle victim if I show that path. I did not.

## Open this, in order

1. This README (the hook)
2. [`reports/live.md`](reports/live.md) then [`reports/fixtures.md`](reports/fixtures.md)
3. [`test/`](test/) — one file per case; live harness is `test/LiveFork.t.sol`
4. [`docs/PRD.md`](docs/PRD.md) if you want the non-goals

## Method (short)

**Fixtures prove the tool.** One boring OZ vault + planted faults. `PreviewLiarVault` is the proof: `preview*` disagrees with `convertTo*`. OZ `deposit` follows `preview*`, so the liar mints extra shares (existing LPs), not a “cheated depositor.”

**Forks are the study.** One `createSelectFork`, pinned block stamped into the report. I will not storage-zero a live pot and call that empty. Leftover-empty and first-depositor on mainnet are **N/A + why**.

**Gift vs deposit needs no source:** `deposit`, then `transfer` the same token to the vault. If `totalAssets` or price moves, they count gifts.

**Preview on live is deposit (+ redeem when it isn’t gated).** Fixtures check all four directional inequalities (`deposit`/`redeem` actual ≥ preview; `mint`/`withdraw` cost ≤ preview). Live does not pretend mint/withdraw ran.

**`totalAssets ≠ balanceOf(vault)` is architecture** at one pin (DSR, Morpho markets, Yearn debt). A gap that opens and closes over time would be the measurable risk. One block cannot show that.

## Run

```bash
# fixtures — no RPC
rm -f reports/fixtures.md
forge test --jobs 1 --no-match-path test/LiveFork.t.sol -vv

# live table — needs MAINNET_RPC_URL (Alchemy public works)
cp .env.example .env   # then set the URL; do not commit .env
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path test/LiveFork.t.sol -vv
```

`--jobs 1` so report rows do not interleave. CI runs fixtures only.

## Fixtures

| Fixture | Role |
|---|---|
| `BaselineVault` | Boring OZ ERC-4626. Preview holds. Gifts count. Leftover / first-depositor are facts. |
| `OffsetVault` | Virtual offset. First-depositor inflation muted (not a safety claim). |
| `PreviewLiarVault` | Planted `preview*` vs `convertTo*`. |
| `StaleNavVault` | Cached NAV. Gifts ignored until `poke()`. |

## License

MIT
