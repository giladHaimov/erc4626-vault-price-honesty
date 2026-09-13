# Test vaults — what the suite proved

These are local demo vaults. No RPC. No mainnet. A Foundry test deploys them, runs a case, and writes this report.

Open this file, not the machine table.

## The vaults

| Vault | What it is |
|---|---|
| `CorrectOzVault` | Plain OpenZeppelin 4626. Clean control. |
| `CorrectOffsetVault` | Same, plus virtual shares. First-depositor wipeout is muted. |
| `FailedPreviewLieVault` | `preview*` lies. OpenZeppelin `deposit` follows the lie. |
| `FailedStaleNavVault` | Cached NAV. A gift does not move price until `poke()`. |
| `MockAsset` | Fake ERC-20 the tests mint. Not a vault. |

## Results

### Unfair mint — first depositor wipeout

**`CorrectOzVault`.** Attacker deposits 1 wei, gifts 10,000 tokens, victim deposits 50 tokens and gets **0 shares**. Attacker can redeem about 5,025 tokens. Victim can redeem 0.

Mark: **unfair mint.** Victim lost the deposit.

**`CorrectOffsetVault`.** Same attack. Victim got 9 shares and can redeem about 45 tokens. Wipeout muted. Not calling that safe — just not wiped.

### Unfair mint — preview lie

**`FailedPreviewLieVault`.** `previewDeposit` promised more shares than `convertToShares`. OpenZeppelin `deposit` minted the lie (about 1,210 shares on a 1,000-token deposit). Existing LPs were diluted.

Mark: **unfair mint.**

**`CorrectOzVault` and `CorrectOffsetVault`.** Preview matched the real call. Pass.

### Gift

**`CorrectOzVault`.** Gift counted. Price went up. Later depositors pay more. Existing LPs gain. Not theft.

**`FailedStaleNavVault`.** Gift did not move price until `poke()`. Stale number.

### Leftover empty

**`CorrectOzVault`.** Last shares redeemed. 500 tokens still in the pot. Next depositor got 1 share and can redeem about 750 tokens (their deposit plus leftover, minus virtual-share math). Next depositor may receive the leftover.

Not marked unfair: often no loser. Say the word if you want this stamped too.

### Helper gap

**`CorrectOzVault`.** N/A. No helper. Tokens sit on the vault.

**`FailedStaleNavVault`.** Cache was 2,500 tokens short. `poke()` closed the gap. Stale cache, not a lying helper.

## Live vaults

`reports/live.md` is a different thing: real vaults already on Ethereum, read from a local snapshot. We did not deploy those.
