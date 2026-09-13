# ERC-4626 vault test report (local fixtures)

This is a **vault test report**, not an audit.
Judgment is **who is hurt**. If no victim is named by the numbers, write `none named`.

| subject | case | ran/N/A | facts | spec | who is hurt |
|---|---|---|---|---|---|
| BaselineVault | FirstDepositor | ran | attackerShares=1 donation=10000e18 victimDeposit=50e18 victimShares=0 attackerPreviewRedeem=5025e18+1 victimPreviewRedeem=0 | victim share count rounds to 0 | victim (almost no shares); attacker can redeem nearly the pot |
| OffsetVault | FirstDepositor | ran | attackerShares=1000 donation=10000e18 victimDeposit=50e18 victimShares=9 attackerPreviewRedeem=5002e18+488800398208063714 victimPreviewRedeem=45e18+22399203583872573 | inflation muted (numbers only; not a safety claim) | none named (offset reduced the rounding wipeout in this fixture) |
| BaselineVault | GiftVsDeposit | ran | taBefore=10000e18 taAfterGift=20000e18 priceBefore=1e18 priceAfter=1e18+999999999999999999 gift=10000e18 | gifts counted | later depositors pay higher price; existing LPs gain (not theft) |
| StaleNavVault | GiftVsDeposit | ran | taBefore=10000e18 taAfterGift=10000e18 balanceAfterGift=20000e18 taAfterPoke=20000e18 gap=10000e18 | stale cache until poke (architecture/helper-gap) | none named until someone acts on the stale number |
| BaselineVault | HelperGap | N/A | totalAssets=7500e18 == balance=7500e18 (no separate helper) | N/A (no helper) | none named |
| StaleNavVault | HelperGap | ran | balance=7500e18 totalAssets=5000e18 gapOpen=2500e18 gapAfterPoke=0 | gap open then closed (stale cache) | none named (architecture/stale cache, not a helper lie) |
| BaselineVault | LeftoverEmpty | ran | aliceShares=1000e18 aliceRedeem=1000e18 leftoverAtEmpty=500e18 bobShares=1 bobDeposit=1000e18 bobPreviewRedeem=750e18 | facts only (no fail for leftover) | none named (next depositor may receive leftover) |
| BaselineVault | PreviewVsActual | ran | dep 1000e18/1000e18; mint 50e18/50e18; wd 100e18/100e18; red 20e18/20e18 | PASS (directional) | none named |
| OffsetVault | PreviewVsActual | ran | dep 1000000e18/1000000e18; mint 50000000000000000/50000000000000000; wd 100000e18/100000e18; red 20000000000000000/20000000000000000 | PASS (directional) | none named |
| PreviewLiarVault | PreviewVsActual | ran | previewDeposit>convertToShares; previewMint<convertToAssets; previewWithdraw<convertToShares; previewRedeem>convertToAssets; OZ deposit minted==lied preview=1210e18+1 | FAIL (preview vs convertTo*; planted) | existing LPs (OZ deposit mints the lied preview); integrators who treat convertTo* as the mint |
