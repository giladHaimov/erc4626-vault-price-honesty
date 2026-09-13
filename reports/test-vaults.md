# Test vaults — what the suite proved

Local demo vaults. No RPC. No mainnet.

`Correct*` = we expect every case we run to pass.
`Failed*` = we planted a fault and expect that case to fail.

| Vault | Folder | We expect |
|---|---|---|
| `FailedFirstDepositorVault` | `src/test-vaults/` | First depositor gets 0 shares. Unfair mint. |
| `CorrectOffsetVault` | `src/test-vaults/` | Same attack, wipeout muted. Preview holds. |
| `FailedPreviewLieVault` | `src/test-vaults/` | `preview*` lies. Extra shares mint. Unfair mint. |
| `FailedStaleNavVault` | `src/test-vaults/` | Gift ignored until `poke()`. Stale price. |
| `MockAsset` | `src/mock/` | Fake ERC-20. Not a vault. |

## Results

### `FailedFirstDepositorVault` — failed first depositor

Attacker deposits 1 wei, gifts 10,000 tokens, victim deposits 50 tokens and gets **0 shares**. Attacker can redeem about 5,025 tokens. Victim can redeem 0.

Bad outcome: **unfair share mint.** Victim paid and got nothing.

Preview on this vault still matched. Gift counted (price up). Leftover-empty: 500 tokens left in the pot; next depositor may receive them.

### `CorrectOffsetVault` — passed the wipeout we ran

Same attack. Victim got 9 shares and can redeem about 45 tokens. Wipeout muted. Preview matched.

### `FailedPreviewLieVault` — failed preview

`previewDeposit` promised more shares than `convertToShares`. Deposit minted the lie (about 1,210 shares on a 1,000-token deposit).

Bad outcome: **unfair share mint.** Existing holders get diluted.

### `FailedStaleNavVault` — failed gift / NAV

Gift did not move price until `poke()`. Cache was 2,500 tokens short, then closed.

Bad outcome: anyone who trusts `totalAssets` before poke sees the wrong share price.

## Live vaults

`reports/live.md` = real vaults already on Ethereum, read from a local snapshot. We did not deploy those.
