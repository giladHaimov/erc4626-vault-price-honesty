# ERC-4626 vault test report

**I measure 4626 pots. I don’t sell a cure.**

[![ci](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml/badge.svg)](https://github.com/giladHaimov/erc4626-vault-test-report/actions/workflows/ci.yml)

Foundry suite. Local **test vaults** prove the tool. A **live snapshot** reads real Ethereum vaults at one block. No mainnet deploy. No mainnet gas.

Not an audit. Not a patched vault.

## Live finding (block `25967333`)

<table>
<tr><td bgcolor="#ffcdd2"><b>FAILED one case — sUSDe (Ethena)</b></td></tr>
<tr><td bgcolor="#ffcdd2">
<b>Which case:</b> gift vs deposit.<br>
<b>What we did:</b> deposit, then send the same token in as a gift.<br>
<b>What happened:</b> share price went up.<br>
<b>Bad outcome:</b> the next depositor pays more for the same share.
</td></tr>
</table>

Preview: no live vault we tested lied.

Empty-pot attacks (leftover / first depositor): not run. Those vaults already have deposits. We will not drain them.

Other vaults we could test: gift did not move price.

Five vaults we could not test (sUSDC, Gauntlet Prime, two Euler, yvUSDT): public RPC snapshot broke. That is our RPC, not their bug.

Full numbers: [`reports/live.md`](reports/live.md). Local proof: [`reports/test-vaults.md`](reports/test-vaults.md).

## Live table

Green = every case that ran passed. Red = at least one case failed. Gray = did not run.

<table>
<tr>
<th></th><th>vault</th><th>simple</th>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>sDAI (Spark)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>sUSDS (Spark)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#ffcdd2">
<td>FAIL</td><td>sUSDe (Ethena)</td><td>Gift moved the share price. Later depositors pay more.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>yvUSDC-1 (Yearn V3)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>yvWETH-1 (Yearn V3)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>yvDAI-1 (Yearn V3)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#eeeeee">
<td>SKIP</td><td>yvUSD (Yearn V3)</td><td>Deposit gated. No preview run.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>yvUSDS-1 (Yearn V3)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>Steakhouse USDC (Morpho)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>Gauntlet USDC Core (Morpho)</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#c8e6c9">
<td>PASS</td><td>sfrxETH</td><td>Preview matched. Gift did not move price.</td>
</tr>
<tr bgcolor="#eeeeee">
<td>SKIP</td><td>sUSDC, Gauntlet Prime, 2 Euler EVK, yvUSDT</td><td>Public snapshot could not call the vault. Not a finding.</td>
</tr>
</table>

## Test vaults

Local. No RPC.

| Vault | We expect | Result |
|---|---|---|
| `FailedFirstDepositorVault` | First depositor wiped | Failed. Victim got 0 shares. Unfair mint. |
| `CorrectOffsetVault` | Wipeout muted | Passed that case. |
| `FailedPreviewLieVault` | Preview lies | Failed. Extra shares minted. Unfair mint. |
| `FailedStaleNavVault` | Stale NAV | Failed. Gift ignored until `poke()`. |

Mock token: `src/mock/MockAsset.sol`.

## Run

```bash
# test vaults — no RPC
rm -f reports/_generated.md
forge test --jobs 1 --no-match-path test/LiveFork.t.sol -vv

# live snapshot — RPC read only, no deploy
cp .env.example .env   # set MAINNET_RPC_URL; do not commit .env
set -a && source .env && set +a
rm -f reports/live.md
forge test --jobs 1 --match-path test/LiveFork.t.sol -vv
```

CI runs test vaults only.

## License

MIT
