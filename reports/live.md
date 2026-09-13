# ERC-4626 vault test report (live mainnet fork)

This is a **vault test report**, not an audit.
Judgment is **who is hurt**. If no victim is named by the numbers, write `none named`.

- Pinned block: `25967333`
- RPC: public Alchemy endpoint (may throttle / 429)
- Fork: single `createSelectFork` for the whole live run

| subject | case | ran/N/A | facts | spec | who is hurt |
|---|---|---|---|---|---|
| sDAI Spark | Snapshot | ran | asset=0x6B175474E89094C44Da98b954EedeAC495271d0F decimals=18 totalAssets=164864514e18+768314139623277514 totalSupply=139659951924435200974441347 balanceOf(vault)=634380338665910200(18dec) block=25967333 | facts | none named |
| sDAI Spark | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sDAI Spark | FirstDepositor | N/A | non-empty live vault supply=139659951924435200974441347 totalAssets=164864514e18+768314139623277514 | N/A (non-empty live) | none named |
| sDAI Spark | HelperGap | N/A | totalAssets=164864514e18+768314139623277514 balanceOf(vault)=634380338665910200(18dec) gap=164864514e18+133933800957367314 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sDAI Spark | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=164864515e18+768314139623277514 taAfter=164864515e18+768314139623277514 priceBefore=1180470940284414453 priceAfter=1180470940284414453 | gifts not counted at pin | none named |
| sDAI Spark | PreviewVsActual | ran | deposit assets=1e18 actualShares=847119540070225666 previewShares=847119540070225666; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| sUSDS Spark | Snapshot | ran | asset=0xdC035D45d973E3EC169d2276DDab16f1e407384F decimals=18 totalAssets=4646909055e18+801526530733720143 totalSupply=4188722467438183907875341762 balanceOf(vault)=4646908805e18+652521124620947399 block=25967333 | facts | none named |
| sUSDS Spark | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sUSDS Spark | FirstDepositor | N/A | non-empty live vault supply=4188722467438183907875341762 totalAssets=4646909055e18+801526530733720143 | N/A (non-empty live) | none named |
| sUSDS Spark | HelperGap | N/A | totalAssets=4646909055e18+801526530733720143 balanceOf(vault)=4646908805e18+652521124620947399 gap=250e18+149005406112772744 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sUSDS Spark | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=4646909056e18+801526530733720142 taAfter=4646909056e18+801526530733720142 priceBefore=1109385759482787796 priceAfter=1109385759482787796 | gifts not counted at pin | none named |
| sUSDS Spark | PreviewVsActual | ran | deposit assets=1e18 actualShares=901399708309051063 previewShares=901399708309051063; redeem actual=249999999999999998(18dec) preview=249999999999999998(18dec) OK | PASS (deposit actual>=preview) | none named |
| sUSDe Ethena | Snapshot | ran | asset=0x4c9EDD5852cd905f086C759E8383e09bff1E68B3 decimals=18 totalAssets=1300459445e18+802426572104651516 totalSupply=1042145195188516846930235363 balanceOf(vault)=1300474351e18+140081334009413420 block=25967333 | facts | none named |
| sUSDe Ethena | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sUSDe Ethena | FirstDepositor | N/A | non-empty live vault supply=1042145195188516846930235363 totalAssets=1300459445e18+802426572104651516 | N/A (non-empty live) | none named |
| sUSDe Ethena | HelperGap | N/A | totalAssets=1300459445e18+802426572104651516 balanceOf(vault)=1300474351e18+140081334009413420 gap=14905e18+337654761904761904 (balance>TA); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sUSDe Ethena | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=1300459446e18+802426572104651516 taAfter=1300459447e18+802426572104651516 priceBefore=1247867813243798976 priceAfter=1247867814203358166 | gifts counted | later depositors pay higher price; existing LPs gain (not theft) |
| sUSDe Ethena | PreviewVsActual | ran | deposit assets=1e18 actualShares=801366930549773351 previewShares=801366930549773351; redeem N/A (cooldown/gated) | PASS (deposit actual>=preview) | none named |
| sUSDC Spark | Verify | ran | asset() flaked on this fork; used allowlist asset 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 at block 25967333 | fork flake (not 'not a 4626') | none named |
| sUSDC Spark | Suite | N/A | vault run revert bytes=empty | N/A (reverted) | none named |
| yvUSDC-1 Yearn V3 | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=19846961e6+579404 totalSupply=17751022988451 balanceOf(vault)=2323e6+609253 block=25967333 | facts | none named |
| yvUSDC-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvUSDC-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=17751022988451 totalAssets=19846961e6+579404 | N/A (non-empty live) | none named |
| yvUSDC-1 Yearn V3 | HelperGap | N/A | totalAssets=19846961e6+579404 balanceOf(vault)=2323e6+609253 gap=19844637e6+970151 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvUSDC-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=19846962e6+579404 taAfter=19846962e6+579404 priceBefore=1118074242386917389 priceAfter=1118074242386917389 | gifts not counted at pin | none named |
| yvUSDC-1 Yearn V3 | PreviewVsActual | ran | deposit assets=1e6 actualShares=894394 previewShares=894394; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| yvWETH-1 Yearn V3 | Snapshot | ran | asset=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 decimals=18 totalAssets=7961e18+110722461349782088 totalSupply=7554290858386673177277 balanceOf(vault)=1e18+2487781008429274 block=25967333 | facts | none named |
| yvWETH-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvWETH-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=7554290858386673177277 totalAssets=7961e18+110722461349782088 | N/A (non-empty live) | none named |
| yvWETH-1 Yearn V3 | HelperGap | N/A | totalAssets=7961e18+110722461349782088 balanceOf(vault)=1e18+2487781008429274 gap=7960e18+108234680341352814 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvWETH-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=10000000000000000(18dec) taBefore=7961e18+120722461349782088 taAfter=7961e18+120722461349782088 priceBefore=1053852819768387737 priceAfter=1053852819768387737 | gifts not counted at pin | none named |
| yvWETH-1 Yearn V3 | PreviewVsActual | ran | deposit assets=10000000000000000(18dec) actualShares=9488991073912737 previewShares=9488991073912737; redeem actual=2499999999999999(18dec) preview=2499999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| yvDAI-1 Yearn V3 | Snapshot | ran | asset=0x6B175474E89094C44Da98b954EedeAC495271d0F decimals=18 totalAssets=7441896e18+553650064022226215 totalSupply=6586146265348655281635326 balanceOf(vault)=26246e18+568121495554646435 block=25967333 | facts | none named |
| yvDAI-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvDAI-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=6586146265348655281635326 totalAssets=7441896e18+553650064022226215 | N/A (non-empty live) | none named |
| yvDAI-1 Yearn V3 | HelperGap | N/A | totalAssets=7441896e18+553650064022226215 balanceOf(vault)=26246e18+568121495554646435 gap=7415649e18+985528568467579780 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvDAI-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=7441897e18+553650064022226215 taAfter=7441897e18+553650064022226215 priceBefore=1129931868170575362 priceAfter=1129931868170575362 | gifts not counted at pin | none named |
| yvDAI-1 Yearn V3 | PreviewVsActual | ran | deposit assets=1e18 actualShares=885009112645931010 previewShares=885009112645931010; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| Steakhouse USDC Morpho | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=67849029e6+865365 totalSupply=59522880902322557510286917 balanceOf(vault)=6011(6dec) block=25967333 | facts | none named |
| Steakhouse USDC Morpho | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| Steakhouse USDC Morpho | FirstDepositor | N/A | non-empty live vault supply=59522880902322557510286917 totalAssets=67849029e6+865365 | N/A (non-empty live) | none named |
| Steakhouse USDC Morpho | HelperGap | N/A | totalAssets=67849029e6+865365 balanceOf(vault)=6011(6dec) gap=67849029e6+859354 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| Steakhouse USDC Morpho | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=67849030e6+865365 taAfter=67849030e6+865365 priceBefore=1139881 priceAfter=1139881 | gifts not counted at pin | none named |
| Steakhouse USDC Morpho | PreviewVsActual | ran | deposit assets=1e6 actualShares=877284238207844411 previewShares=877284238207844411; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| Gauntlet USDC Prime Morpho | Verify | ran | asset() flaked on this fork; used allowlist asset 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 at block 25967333 | fork flake (not 'not a 4626') | none named |
| Gauntlet USDC Prime Morpho | Suite | N/A | vault run revert bytes=empty | N/A (reverted) | none named |
| Gauntlet USDC Core Morpho | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=3789956e6+656431 totalSupply=4587775661959903641353830 balanceOf(vault)=0 block=25967333 | facts | none named |
| Gauntlet USDC Core Morpho | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| Gauntlet USDC Core Morpho | FirstDepositor | N/A | non-empty live vault supply=4587775661959903641353830 totalAssets=3789956e6+656431 | N/A (non-empty live) | none named |
| Gauntlet USDC Core Morpho | HelperGap | N/A | totalAssets=3789956e6+656431 balanceOf(vault)=0 gap=3789956e6+656431 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| Gauntlet USDC Core Morpho | GiftVsDeposit | ran | deposit ok; gift=1e6 taBefore=3789957e6+656431 taAfter=3789957e6+656431 priceBefore=826080 priceAfter=826080 | gifts not counted at pin | none named |
| Gauntlet USDC Core Morpho | PreviewVsActual | ran | deposit assets=1e6 actualShares=1210536501910353212 previewShares=1210536501910353212; redeem actual=249999(6dec) preview=249999(6dec) OK | PASS (deposit actual>=preview) | none named |
| EVK esUSDS-4 Euler | Verify | ran | asset() flaked on this fork; used allowlist asset 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD at block 25967333 | fork flake (not 'not a 4626') | none named |
| EVK esUSDS-4 Euler | Suite | N/A | vault run revert bytes=empty | N/A (reverted) | none named |
| EVK esDAI-2 Euler | Verify | ran | asset() flaked on this fork; used allowlist asset 0x83F20F44975D03b1b09e64809B757c47f942BEeA at block 25967333 | fork flake (not 'not a 4626') | none named |
| EVK esDAI-2 Euler | Suite | N/A | vault run revert bytes=empty | N/A (reverted) | none named |
| sfrxETH | Snapshot | ran | asset=0x5E8422345238F34275888049021821E8E08CAa1f decimals=18 totalAssets=43234e18+703616621390954104 totalSupply=36977995157724832658782 balanceOf(vault)=43246e18+77044018746406396 block=25967333 | facts | none named |
| sfrxETH | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| sfrxETH | FirstDepositor | N/A | non-empty live vault supply=36977995157724832658782 totalAssets=43234e18+703616621390954104 | N/A (non-empty live) | none named |
| sfrxETH | HelperGap | N/A | totalAssets=43234e18+703616621390954104 balanceOf(vault)=43246e18+77044018746406396 gap=11e18+373427397355452292 (balance>TA); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| sfrxETH | GiftVsDeposit | ran | deposit ok; gift=10000000000000000(18dec) taBefore=43234e18+713616621390954104 taAfter=43234e18+713616621390954104 priceBefore=1169200856677312587 priceAfter=1169200856677312587 | gifts not counted at pin | none named |
| sfrxETH | PreviewVsActual | ran | deposit assets=10000000000000000(18dec) actualShares=8552850387416280 previewShares=8552850387416280; redeem actual=2499999999999999(18dec) preview=2499999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| yvUSD Yearn V3 | Snapshot | ran | asset=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 decimals=6 totalAssets=9362440e6+749568 totalSupply=9097577577387 balanceOf(vault)=6001(6dec) block=25967333 | facts | none named |
| yvUSD Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvUSD Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=9097577577387 totalAssets=9362440e6+749568 | N/A (non-empty live) | none named |
| yvUSD Yearn V3 | HelperGap | N/A | totalAssets=9362440e6+749568 balanceOf(vault)=6001(6dec) gap=9362440e6+743567 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvUSD Yearn V3 | GiftVsDeposit | ran | deposit N/A (deposit revert bytes=empty); gift=1e6 taBefore=9362440e6+749568 taAfter=9362440e6+749568 priceBefore=1029113593143667791 priceAfter=1029113593143667791 | gifts not counted at pin (deposit gated) | none named |
| yvUSD Yearn V3 | PreviewVsActual | N/A | deposit revert: empty (maxDeposit was 5637559250432) | N/A gated | none named |
| yvUSDS-1 Yearn V3 | Snapshot | ran | asset=0xdC035D45d973E3EC169d2276DDab16f1e407384F decimals=18 totalAssets=7285289e18+920648991205293023 totalSupply=6571806006214650087715745 balanceOf(vault)=10e18+54 block=25967333 | facts | none named |
| yvUSDS-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvUSDS-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=6571806006214650087715745 totalAssets=7285289e18+920648991205293023 | N/A (non-empty live) | none named |
| yvUSDS-1 Yearn V3 | HelperGap | N/A | totalAssets=7285289e18+920648991205293023 balanceOf(vault)=10e18+54 gap=7285279e18+920648991205292969 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvUSDS-1 Yearn V3 | GiftVsDeposit | ran | deposit ok; gift=1e18 taBefore=7285290e18+920648991205293023 taAfter=7285290e18+920648991205293023 priceBefore=1108567403505160178 priceAfter=1108567403505160178 | gifts not counted at pin | none named |
| yvUSDS-1 Yearn V3 | PreviewVsActual | ran | deposit assets=1e18 actualShares=902065130941174370 previewShares=902065130941174370; redeem actual=249999999999999999(18dec) preview=249999999999999999(18dec) OK | PASS (deposit actual>=preview) | none named |
| yvUSDT-1 Yearn V3 | Snapshot | ran | asset=0xdAC17F958D2ee523a2206206994597C13D831ec7 decimals=6 totalAssets=5778372e6+551683 totalSupply=5290329264939 balanceOf(vault)=54944(6dec) block=25967333 | facts | none named |
| yvUSDT-1 Yearn V3 | LeftoverEmpty | N/A | live pot; do not storage-zero to manufacture empty supply | N/A (live) | none named |
| yvUSDT-1 Yearn V3 | FirstDepositor | N/A | non-empty live vault supply=5290329264939 totalAssets=5778372e6+551683 | N/A (non-empty live) | none named |
| yvUSDT-1 Yearn V3 | HelperGap | N/A | totalAssets=5778372e6+551683 balanceOf(vault)=54944(6dec) gap=5778372e6+496739 (TA>balance); single pinned block - not shown opening/closing | N/A architecture (idle balance != accounting NAV) | none named |
| yvUSDT-1 Yearn V3 | Suite | N/A | vault run revert bytes=empty | N/A (reverted) | none named |
