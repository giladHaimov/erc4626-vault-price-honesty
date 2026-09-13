# ERC-4626 vault test report

**I measure 4626 pots. I don’t sell a cure.**

[![ci](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml/badge.svg)](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml)

A Foundry suite that measures ERC-4626 vaults and writes a test report. Judgment is **who is hurt**, not vulnerable/safe.

Two layers:

1. **Test vaults** (local, no RPC) — a clean OpenZeppelin vault and planted-fault vaults. This is how we know the suite works. Read [`reports/test-vaults.md`](reports/test-vaults.md).
2. **Live snapshot** — Foundry copies Ethereum at one block onto your machine and runs the same cases against real vaults already on mainnet (sDAI, Yearn, Morpho, …). No mainnet gas. We did not deploy those vaults. Full table: [`reports/live.md`](reports/live.md).

This is **not an audit** and not a patched vault.

## Test vaults

| Vault | Role |
|---|---|
| `CorrectOzVault` | Plain OpenZeppelin 4626. Clean control. |
| `CorrectOffsetVault` | Virtual shares. First-depositor wipeout muted. |
| `FailedPreviewLieVault` | `preview*` lies. Deposit mints the lie. |
| `FailedStaleNavVault` | Cached NAV. Gifts ignored until `poke()`. |

We mark **unfair mint** when a victim is named: first-depositor wipeout (0 shares) and the preview lie (extra shares minted). Leftover-empty is measured and not stamped unless you want that stamp — the next depositor can still take the leftover tokens.

## Last live run — block `25967333`

Public Alchemy snapshot. **11 vaults completed cases.** Four others have code on the snapshot but `asset()` empty-reverts here (the public RPC does not follow some proxies). Same addresses answer `cast call`. That is a snapshot limit, not “not a 4626.”

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
| sUSDC / Gauntlet Prime / 2 Euler EVK / yvUSDT | — | — | — | — | snapshot `asset()`/run revert; `cast call` works |

A price jump alone is not a fee bug. I only name a fee/oracle victim if I show that path. I did not.

## Run

```bash
# test vaults — no RPC
rm -f reports/_generated.md
forge test --jobs 1 --no-match-path test/LiveFork.t.sol -vv

# live snapshot — needs MAINNET_RPC_URL (Alchemy public works)
cp .env.example .env   # then set the URL; do not commit .env
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path test/LiveFork.t.sol -vv
```

`--jobs 1` so report rows do not interleave. CI runs test vaults only.

## License

MIT
