# Phases

| Phase | Scope |
|---|---|
| **1 (done)** | Local fixtures + 5 cases. `forge test` green with no RPC. Writes `reports/fixtures.md`. |
| **2 (done)** | Live mainnet-fork table at pinned block `25967282`. 9 of 13 vaults ran; 4 `asset()` drops on public Alchemy (see allowlist). Writes `reports/live.md`. |

Not an audit. Judgment column is **who is hurt**.

## Phase 1 command

```bash
rm -f reports/fixtures.md   # clear so rows are not duplicated across re-runs
forge test --jobs 1 --match-path 'test/{FirstDepositor,GiftVsDeposit,HelperGap,LeftoverEmpty,PreviewVsActual}.t.sol' -vv
# or full suite without RPC — live tests skip:
forge test --jobs 1 -vv
```

## Phase 2 command

```bash
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path 'test/Live*.t.sol' -vv
```

`--jobs 1` keeps report appends ordered. Live fork uses a single `createSelectFork` for the whole allowlist. Public Alchemy may throttle.
