# Phases

| Phase | Scope |
|---|---|
| **1 (now)** | Local fixtures + 5 cases. `forge test` green with no RPC. Writes `reports/fixtures.md`. |
| **2** | Live mainnet-fork checks against an allowlist (`docs/live-allowlist.md`) at pinned blocks. Requires `MAINNET_RPC_URL`. |

Not an audit. Judgment column is **who is hurt**.

## Phase 1 command

```bash
rm -f reports/fixtures.md   # clear so rows are not duplicated across re-runs
forge test --jobs 1 -vv
```

`--jobs 1` keeps report appends ordered. Live fork tests skip when `MAINNET_RPC_URL` is unset.
