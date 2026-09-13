# Live vault allowlist (Phase 2)

Last published run: pinned block `25967333` (public Alchemy fork). See `reports/live.md`.

| address | name | last run | notes |
|---|---|---|---|
| `0x83F20F44975D03b1b09e64809B757c47f942BEeA` | sDAI Spark | ran | Preview PASS. Gifts not counted. TA >> idle (DSR). |
| `0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD` | sUSDS Spark | ran | Preview PASS. Gifts not counted. |
| `0x9D39A5DE30e57443BfF2A8307A4256c8797A3497` | sUSDe Ethena | ran | Preview PASS. **Gifts counted.** Redeem cooldown. |
| `0xBc65ad17c5C0a2A4D159fa5a503f4992c7B545FE` | sUSDC Spark | fork gap | Proxy; `cast call asset()` works; Foundry fork `asset()` empty-reverts. |
| `0xBe53A109B494E5c9f97b9Cd39Fe969BE68BF6204` | yvUSDC-1 Yearn V3 | ran | Preview PASS. |
| `0xc56413869c6CDf96496f2b1eF801fEDBdFA7dDB0` | yvWETH-1 Yearn V3 | ran | Preview PASS. |
| `0x028eC7330ff87667b6dfb0D94b954c820195336c` | yvDAI-1 Yearn V3 | ran | Preview PASS. |
| `0x696d02Db93291651ED510704c9b286841d506987` | yvUSD Yearn V3 | ran | Deposit gated at pin. Gifts not counted. |
| `0x182863131F9a4630fF9E27830d945B1413e347E8` | yvUSDS-1 Yearn V3 | ran | Preview PASS. |
| `0x310B7Ea7475A0B449Cfd73bE81522F1B88eFAFaa` | yvUSDT-1 Yearn V3 | fork gap | Suite revert on this public fork (USDT deal/blacklist likely). |
| `0xBEEF01735c132Ada46AA9aA4c54623cAA92A64CB` | Steakhouse USDC Morpho | ran | Preview PASS. |
| `0x8c106EEDAd96553e64287A5A6839c3Cc78afA3D0` | Gauntlet USDC Prime Morpho | fork gap | Code present; `asset()` empty-reverts on this fork. |
| `0x8eB67A509616cd6A7c1B3c8C21D48FF57df3d458` | Gauntlet USDC Core Morpho | ran | Preview PASS. Idle USDC 0. |
| `0x1cA03621265D9092dC0587e1b50aB529f744aacB` | EVK esUSDS-4 Euler | fork gap | Proxy; `cast call` works; fork does not follow impl. |
| `0x8E4AF2F36ed6fb03E5E02Ab9f3C724B6E44C13b4` | EVK esDAI-2 Euler | fork gap | Same as esUSDS. |
| `0xac3E018457B222d93114458476f3E3416Abbe38F` | sfrxETH | ran | Preview PASS. |

Leftover-empty and first-depositor are **N/A** on every live pot. Helper gap is **N/A architecture** at one pin.

`LiveFork.t.sol` skips when `MAINNET_RPC_URL` is unset.
