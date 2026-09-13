# ERC-4626 vault test report (live mainnet fork)

This is a **vault test report**, not an audit.
Judgment is **who is hurt**. If no victim is named by the numbers, write `none named`.

- Pinned block: `25967282`
- RPC: public Alchemy endpoint (may throttle / 429)
- Fork: single `createSelectFork` for the whole live run

| subject | case | ran/N/A | facts | spec | who is hurt |
|---|---|---|---|---|---|
| sDAI Spark | Snapshot | ran | asset=0x6B175474E89094C44Da98b954EedeAC495271d0F decimals=18 totalAssets=164864475e18+23391487536894614 totalSupply=139659951924435200974441347 balanceOf(vault)=634380338665910200(18dec) block=25967282 | facts | none named |
| sDAI Spark | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sDAI Spark | FirstDepositor | N/A | non-empty live vault supply=139659951924435200974441347 totalAssets=164864475e18+23391487536894614 | N/A (non-empty live) | none named |
| sDAI Spark | HelperGap | N/A | totalAssets=164864475e18+23391487536894614 balanceOf(vault)=634380338665910200(18dec) gap=164864474e18+389011148870984414 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sDAI Spark | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=164864476e18+23391487536894613 taAfter=164864476e18+23391487536894613 priceBefore=1180470655700880631 priceAfter=1180470655700880631 | gifts not counted at pin | none named |
| sDAI Spark | PreviewVsActual | ran | deposit assets=1e18 actualShares=847119744290695797 previewShares=847119744290695797; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| sUSDS Spark | Snapshot | ran | asset=0xdC035D45d973E3EC169d2276DDab16f1e407384F decimals=18 totalAssets=4646907345e18+962379517585277491 totalSupply=4188723801113748143997189427 balanceOf(vault)=4646906720e18+590121357762133539 block=25967282 | facts | none named |
| sUSDS Spark | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sUSDS Spark | FirstDepositor | N/A | non-empty live vault supply=4188723801113748143997189427 totalAssets=4646907345e18+962379517585277491 | N/A (non-empty live) | none named |
| sUSDS Spark | HelperGap | N/A | totalAssets=4646907345e18+962379517585277491 balanceOf(vault)=4646906720e18+590121357762133539 gap=625e18+372258159823143952 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sUSDS Spark | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=4646907346e18+962379517585277491 taAfter=4646907346e18+962379517585277491 priceBefore=1109384998057595498 priceAfter=1109384998057595498 | gifts not counted at pin | none named |
| sUSDS Spark | PreviewVsActual | ran | deposit assets=1e18 actualShares=901400326983764926 previewShares=901400326983764926; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| sUSDe Ethena | Snapshot | ran | asset=0x4c9EDD5852cd905f086C759E8383e09bff1E68B3 decimals=18 totalAssets=1300458199e18+618458714961794373 totalSupply=1042145195188516846930235363 balanceOf(vault)=1300474351e18+140081334009413420 block=25967282 | facts | none named |
| sUSDe Ethena | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sUSDe Ethena | FirstDepositor | N/A | non-empty live vault supply=1042145195188516846930235363 totalAssets=1300458199e18+618458714961794373 | N/A (non-empty live) | none named |
| sUSDe Ethena | HelperGap | N/A | totalAssets=1300458199e18+618458714961794373 balanceOf(vault)=1300474351e18+140081334009413420 gap=16151e18+521622619047619047 (balance>TA); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sUSDe Ethena | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=1300458200e18+618458714961794373 taAfter=1300458201e18+618458714961794373 priceBefore=1247866617456519419 priceAfter=1247866618416078609 | gifts counted | later depositors pay higher price; existing LPs gain (not theft) |
| sUSDe Ethena | PreviewVsActual | ran | deposit assets=1e18 actualShares=801367698471895529 previewShares=801367698471895529; redeem N/A (cooldown/gated) | PASS (deposit actual>=preview) | none named |
| sUSDC Spark | Verify | N/A | asset() failed at block 25967282 | dropped (asset() failed) | none named |
| yvUSDC-1 Yearn V3 | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=19846961e6+579404 totalSupply=17751031370266 balanceOf(vault)=2323e6+609253 block=25967282 | facts | none named |
| yvUSDC-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvUSDC-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=17751031370266 totalAssets=19846961e6+579404 | N/A (non-empty live) | none named |
| yvUSDC-1 Yearn V3 | HelperGap | N/A | totalAssets=19846961e6+579404 balanceOf(vault)=2323e6+609253 gap=19844637e6+970151 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvUSDC-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=19846962e6+579404 taAfter=19846962e6+579404 priceBefore=1118073714446207559 priceAfter=1118073714446207559 | gifts not counted at pin | none named |
| yvUSDC-1 Yearn V3 | PreviewVsActual | ran | deposit assets=1e6 actualShares=894395 previewShares=894395; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| yvWETH-1 Yearn V3 | Snapshot | ran | asset=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 decimals=18 totalAssets=7961e18+110722461349782088 totalSupply=7554293662602656289279 balanceOf(vault)=1e18+2487781008429274 block=25967282 | facts | none named |
| yvWETH-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvWETH-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=7554293662602656289279 totalAssets=7961e18+110722461349782088 | N/A (non-empty live) | none named |
| yvWETH-1 Yearn V3 | HelperGap | N/A | totalAssets=7961e18+110722461349782088 balanceOf(vault)=1e18+2487781008429274 gap=7960e18+108234680341352814 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvWETH-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=10000000000000000(18dec) taBefore=7961e18+120722461349782088 taAfter=7961e18+120722461349782088 priceBefore=1053852428569547312 priceAfter=1053852428569547312 | gifts not counted at pin | none named |
| yvWETH-1 Yearn V3 | PreviewVsActual | ran | deposit assets=10000000000000000(18dec) actualShares=9488994596305630 previewShares=9488994596305630; redeem actual=2499999999999999(18dec) preview=2499999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| yvDAI-1 Yearn V3 | Snapshot | ran | asset=0x6B175474E89094C44Da98b954EedeAC495271d0F decimals=18 totalAssets=7441896e18+553650064022226215 totalSupply=6586148784879280946968820 balanceOf(vault)=26246e18+568121495554646435 block=25967282 | facts | none named |
| yvDAI-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvDAI-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=6586148784879280946968820 totalAssets=7441896e18+553650064022226215 | N/A (non-empty live) | none named |
| yvDAI-1 Yearn V3 | HelperGap | N/A | totalAssets=7441896e18+553650064022226215 balanceOf(vault)=26246e18+568121495554646435 gap=7415649e18+985528568467579780 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvDAI-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=7441897e18+553650064022226215 taAfter=7441897e18+553650064022226215 priceBefore=1129931435915240757 priceAfter=1129931435915240757 | gifts not counted at pin | none named |
| yvDAI-1 Yearn V3 | PreviewVsActual | ran | deposit assets=1e18 actualShares=885009451206217021 previewShares=885009451206217021; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| Steakhouse USDC Morpho | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=67848976e6+351877 totalSupply=59522880902322557510286917 balanceOf(vault)=6011(6dec) block=25967282 | facts | none named |
| Steakhouse USDC Morpho | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| Steakhouse USDC Morpho | FirstDepositor | N/A | non-empty live vault supply=59522880902322557510286917 totalAssets=67848976e6+351877 | N/A (non-empty live) | none named |
| Steakhouse USDC Morpho | HelperGap | N/A | totalAssets=67848976e6+351877 balanceOf(vault)=6011(6dec) gap=67848976e6+345866 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| Steakhouse USDC Morpho | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=67848977e6+351877 taAfter=67848977e6+351877 priceBefore=1139880 priceAfter=1139880 | gifts not counted at pin | none named |
| Steakhouse USDC Morpho | PreviewVsActual | ran | deposit assets=1e6 actualShares=877284895538525667 previewShares=877284895538525667; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| Gauntlet USDC Prime Morpho | Verify | N/A | asset() failed at block 25967282 | dropped (asset() failed) | none named |
| Gauntlet USDC Core Morpho | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=3789953e6+361305 totalSupply=4587775661959903641353830 balanceOf(vault)=0 block=25967282 | facts | none named |
| Gauntlet USDC Core Morpho | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| Gauntlet USDC Core Morpho | FirstDepositor | N/A | non-empty live vault supply=4587775661959903641353830 totalAssets=3789953e6+361305 | N/A (non-empty live) | none named |
| Gauntlet USDC Core Morpho | HelperGap | N/A | totalAssets=3789953e6+361305 balanceOf(vault)=0 gap=3789953e6+361305 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| Gauntlet USDC Core Morpho | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=3789954e6+361305 taAfter=3789954e6+361305 priceBefore=826079 priceAfter=826079 | gifts not counted at pin | none named |
| Gauntlet USDC Core Morpho | PreviewVsActual | ran | deposit assets=1e6 actualShares=1210537501794076255 previewShares=1210537501794076255; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| EVK esUSDS-4 Euler | Verify | N/A | asset() failed at block 25967282 | dropped (asset() failed) | none named |
| EVK esDAI-2 Euler | Verify | N/A | asset() failed at block 25967282 | dropped (asset() failed) | none named |
| sfrxETH | Snapshot | ran | asset=0x5E8422345238F34275888049021821E8E08CAa1f decimals=18 totalAssets=43234e18+681511325843806017 totalSupply=36977995157724832658782 balanceOf(vault)=43246e18+77044018746406396 block=25967282 | facts | none named |
| sfrxETH | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sfrxETH | FirstDepositor | N/A | non-empty live vault supply=36977995157724832658782 totalAssets=43234e18+681511325843806017 | N/A (non-empty live) | none named |
| sfrxETH | HelperGap | N/A | totalAssets=43234e18+681511325843806017 balanceOf(vault)=43246e18+77044018746406396 gap=11e18+395532692902600379 (balance>TA); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sfrxETH | GiftVsDeposit | ran | deposit ok; gift=10000000000000000(18dec) taBefore=43234e18+691511325843806017 taAfter=43234e18+691511325843806017 priceBefore=1169200258881367922 priceAfter=1169200258881367922 | gifts not counted at pin | none named |
| sfrxETH | PreviewVsActual | ran | deposit assets=10000000000000000(18dec) actualShares=8552854760370561 previewShares=8552854760370561; redeem actual=2499999999999999(18dec) preview=2499999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
