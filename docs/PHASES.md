# Phases

| Phase | Scope |
|---|---|
| **1 (done)** | Local test vaults + 5 cases. `forge test` green with no RPC. Human report: `reports/test-vaults.md`. |
| **2 (done)** | Live snapshot table at pinned block `25967333`. 11 vaults ran; 4 public-snapshot proxy gaps documented. Writes `reports/live.md`. |

Not an audit. Judgment column is **who is hurt**.

## Phase 1 command

```bash
rm -f reports/_generated.md
forge test --jobs 1 --no-match-path test/LiveFork.t.sol -vv
```

## Phase 2 command

```bash
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path test/LiveFork.t.sol -vv
```

`--jobs 1` keeps generated rows ordered. Live uses a single `createSelectFork` for the whole allowlist.
