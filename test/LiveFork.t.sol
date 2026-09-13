// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {LiveReport} from "../src/report/LiveReport.sol";

/// @notice Phase 2: live mainnet-fork checks against the allowlist at one pinned block.
/// @dev Skip entire suite when MAINNET_RPC_URL is unset so CI stays green without RPC.
contract LiveForkTest is Test {
    struct VaultSpec {
        address vault;
        string name;
        address expectedAsset;
        bool ethLike;
    }

    bool internal forked;
    uint256 internal pinnedBlock;

    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant FRXETH = 0x5E8422345238F34275888049021821E8E08CAa1f;

    function setUp() public {
        string memory rpc = vm.envOr("MAINNET_RPC_URL", string(""));
        if (bytes(rpc).length == 0) {
            return;
        }
        // createSelectFork returns forkId — pin block.number after select.
        vm.createSelectFork(rpc);
        pinnedBlock = block.number;
        forked = true;
        LiveReport.init(pinnedBlock);
    }

    function test_liveAllowlist_cases() public {
        if (!forked) {
            vm.skip(true, "P2: needs MAINNET_RPC_URL");
        }

        vm.pauseGasMetering();

        VaultSpec[] memory specs = _specs();
        uint256 ranVaults = 0;

        for (uint256 i = 0; i < specs.length; i++) {
            // Isolate each vault so one hard revert does not kill the suite.
            try this.runOneVault(specs[i]) returns (bool included) {
                if (included) ranVaults++;
            } catch Error(string memory reason) {
                LiveReport.row(specs[i].name, "Suite", "N/A", string.concat("vault run revert: ", reason), "N/A (reverted)", "none named");
            } catch (bytes memory data) {
                LiveReport.row(
                    specs[i].name,
                    "Suite",
                    "N/A",
                    string.concat("vault run revert bytes=", _bytesPreview(data)),
                    "N/A (reverted)",
                    "none named"
                );
            }
        }

        assertGt(ranVaults, 0, "at least one vault should verify");
        emit log_named_uint("pinnedBlock", pinnedBlock);
        emit log_named_uint("vaultsRan", ranVaults);
    }

    /// @dev External so try/catch can isolate state-reverting vault runs.
    function runOneVault(VaultSpec memory s) external returns (bool included) {
        (bool ok, address asset) = _tryAsset(s.vault);
        if (!ok) {
            // one retry — public RPC sometimes flakes
            (ok, asset) = _tryAsset(s.vault);
        }
        if (!ok) {
            // Public RPC forks flake on some proxies. Allowlist asset was already
            // checked with eth_call — keep measuring, do not invent a new address.
            if (s.expectedAsset == address(0)) {
                LiveReport.row(
                    s.name,
                    "Verify",
                    "N/A",
                    string.concat("asset() failed at block ", LiveReport.u(pinnedBlock), " and no allowlist asset"),
                    "dropped (asset() failed)",
                    "none named"
                );
                return false;
            }
            asset = s.expectedAsset;
            LiveReport.row(
                s.name,
                "Verify",
                "ran",
                string.concat(
                    "asset() flaked on this fork; used allowlist asset ",
                    vm.toString(asset),
                    " at block ",
                    LiveReport.u(pinnedBlock)
                ),
                "fork flake (not 'not a 4626')",
                "none named"
            );
        }
        if (s.expectedAsset != address(0) && asset != s.expectedAsset) {
            LiveReport.row(
                s.name,
                "Verify",
                "N/A",
                string.concat("asset()=", vm.toString(asset), " expected=", vm.toString(s.expectedAsset)),
                "dropped (asset mismatch)",
                "none named"
            );
            return false;
        }
        _runVault(s, asset);
        return true;
    }

    function _specs() internal pure returns (VaultSpec[] memory specs) {
        specs = new VaultSpec[](16);
        specs[0] = VaultSpec(0x83F20F44975D03b1b09e64809B757c47f942BEeA, "sDAI Spark", 0x6B175474E89094C44Da98b954EedeAC495271d0F, false);
        specs[1] = VaultSpec(0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD, "sUSDS Spark", 0xdC035D45d973E3EC169d2276DDab16f1e407384F, false);
        specs[2] = VaultSpec(0x9D39A5DE30e57443BfF2A8307A4256c8797A3497, "sUSDe Ethena", 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3, false);
        specs[3] = VaultSpec(0xBc65ad17c5C0a2A4D159fa5a503f4992c7B545FE, "sUSDC Spark", USDC, false);
        specs[4] = VaultSpec(0xBe53A109B494E5c9f97b9Cd39Fe969BE68BF6204, "yvUSDC-1 Yearn V3", USDC, false);
        specs[5] = VaultSpec(0xc56413869c6CDf96496f2b1eF801fEDBdFA7dDB0, "yvWETH-1 Yearn V3", WETH, true);
        specs[6] = VaultSpec(0x028eC7330ff87667b6dfb0D94b954c820195336c, "yvDAI-1 Yearn V3", 0x6B175474E89094C44Da98b954EedeAC495271d0F, false);
        specs[7] = VaultSpec(0xBEEF01735c132Ada46AA9aA4c54623cAA92A64CB, "Steakhouse USDC Morpho", USDC, false);
        specs[8] = VaultSpec(0x8c106EEDAd96553e64287A5A6839c3Cc78afA3D0, "Gauntlet USDC Prime Morpho", USDC, false);
        specs[9] = VaultSpec(0x8eB67A509616cd6A7c1B3c8C21D48FF57df3d458, "Gauntlet USDC Core Morpho", USDC, false);
        specs[10] = VaultSpec(0x1cA03621265D9092dC0587e1b50aB529f744aacB, "EVK esUSDS-4 Euler", 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD, false);
        specs[11] = VaultSpec(0x8E4AF2F36ed6fb03E5E02Ab9f3C724B6E44C13b4, "EVK esDAI-2 Euler", 0x83F20F44975D03b1b09e64809B757c47f942BEeA, false);
        specs[12] = VaultSpec(0xac3E018457B222d93114458476f3E3416Abbe38F, "sfrxETH", FRXETH, true);
        specs[13] = VaultSpec(0x696d02Db93291651ED510704c9b286841d506987, "yvUSD Yearn V3", USDC, false);
        specs[14] = VaultSpec(0x182863131F9a4630fF9E27830d945B1413e347E8, "yvUSDS-1 Yearn V3", 0xdC035D45d973E3EC169d2276DDab16f1e407384F, false);
        specs[15] = VaultSpec(0x310B7Ea7475A0B449Cfd73bE81522F1B88eFAFaa, "yvUSDT-1 Yearn V3", 0xdAC17F958D2ee523a2206206994597C13D831ec7, false);
    }

    function _tryAsset(address vault) internal view returns (bool ok, address asset) {
        try IERC4626(vault).asset() returns (address a) {
            if (a != address(0)) return (true, a);
        } catch {}
        (bool success, bytes memory data) = vault.staticcall(abi.encodeWithSelector(IERC4626.asset.selector));
        if (success && data.length >= 32) {
            asset = abi.decode(data, (address));
            if (asset != address(0)) return (true, asset);
        }
        return (false, address(0));
    }

    function _depositSize(address asset, uint8 decimals, bool ethLike) internal pure returns (uint256) {
        if (ethLike || asset == WETH || asset == FRXETH) return 0.01e18;
        if (decimals == 6) return 1e6;
        if (decimals == 8) return 1e8;
        return 1e18;
    }

    function _runVault(VaultSpec memory s, address asset) internal {
        IERC4626 vault = IERC4626(s.vault);
        uint8 dec = _assetDecimals(asset);
        uint256 ta = vault.totalAssets();
        uint256 supply = vault.totalSupply();
        uint256 bal = IERC20(asset).balanceOf(s.vault);
        uint256 size = _depositSize(asset, dec, s.ethLike);

        LiveReport.row(
            s.name,
            "Snapshot",
            "ran",
            string.concat(
                "asset=",
                vm.toString(asset),
                " decimals=",
                LiveReport.u(dec),
                " totalAssets=",
                LiveReport.qty(ta, dec),
                " totalSupply=",
                LiveReport.u(supply),
                " balanceOf(vault)=",
                LiveReport.qty(bal, dec),
                " block=",
                LiveReport.u(pinnedBlock)
            ),
            "facts",
            "none named"
        );

        LiveReport.row(
            s.name,
            "LeftoverEmpty",
            "N/A",
            "live pot; do not storage-zero to manufacture empty supply",
            "N/A (live)",
            "none named"
        );

        if (supply == 0 && ta == 0) {
            LiveReport.row(
                s.name,
                "FirstDepositor",
                "N/A",
                "supply=0 and totalAssets=0 at pin; inflation path not exercised on live",
                "N/A (not exercised)",
                "none named"
            );
        } else {
            LiveReport.row(
                s.name,
                "FirstDepositor",
                "N/A",
                string.concat(
                    "non-empty live vault supply=",
                    LiveReport.u(supply),
                    " totalAssets=",
                    LiveReport.qty(ta, dec)
                ),
                "N/A (non-empty live)",
                "none named"
            );
        }

        _caseHelperGap(s.name, ta, bal, dec);
        _caseGiftVsDeposit(s.name, vault, asset, size, dec);
        _casePreviewVsActual(s.name, vault, asset, size, dec);
    }

    function _assetDecimals(address asset) internal view returns (uint8) {
        try IERC20Metadata(asset).decimals() returns (uint8 d) {
            return d;
        } catch {
            return 18;
        }
    }

    function _caseHelperGap(string memory subject, uint256 ta, uint256 bal, uint8 dec) internal {
        if (ta == bal) {
            LiveReport.row(
                subject,
                "HelperGap",
                "N/A",
                string.concat(
                    "totalAssets=",
                    LiveReport.qty(ta, dec),
                    " == balanceOf(vault)=",
                    LiveReport.qty(bal, dec)
                ),
                "N/A (no gap at pin)",
                "none named"
            );
            return;
        }
        string memory side = ta > bal ? "TA>balance" : "balance>TA";
        uint256 gap = ta > bal ? ta - bal : bal - ta;
        LiveReport.row(
            subject,
            "HelperGap",
            "N/A",
            string.concat(
                "totalAssets=",
                LiveReport.qty(ta, dec),
                " balanceOf(vault)=",
                LiveReport.qty(bal, dec),
                " gap=",
                LiveReport.qty(gap, dec),
                " (",
                side,
                "); single pinned block - not shown opening/closing"
            ),
            "N/A architecture (idle balance != accounting NAV)",
            "none named"
        );
    }

    function _caseGiftVsDeposit(
        string memory subject,
        IERC4626 vault,
        address asset,
        uint256 size,
        uint8 dec
    ) internal {
        address depositor = makeAddr(string.concat("dep-", subject));
        address gifter = makeAddr(string.concat("gift-", subject));

        if (!_fund(asset, depositor, size * 2)) {
            LiveReport.row(subject, "GiftVsDeposit", "N/A", "deal(asset) failed (blacklist / nonstandard storage)", "N/A (deal failed)", "none named");
            return;
        }
        if (!_fund(asset, gifter, size)) {
            LiveReport.row(subject, "GiftVsDeposit", "N/A", "deal(asset) to gifter failed", "N/A (deal failed)", "none named");
            return;
        }

        (bool depositOk, string memory depositNote) = _attemptDeposit(vault, asset, depositor, size);

        if (!depositOk) {
            uint256 ta0 = vault.totalAssets();
            uint256 price0 = _pricePerShare(vault);
            (bool giftOk, string memory giftNote) = _attemptGift(asset, gifter, address(vault), size);
            if (!giftOk) {
                LiveReport.row(
                    subject,
                    "GiftVsDeposit",
                    "N/A",
                    string.concat(depositNote, "; ", giftNote),
                    "N/A gated (deposit+gift)",
                    "none named"
                );
                return;
            }
            uint256 ta1 = vault.totalAssets();
            uint256 price1 = _pricePerShare(vault);
            bool counts = ta1 != ta0 || price1 != price0;
            LiveReport.row(
                subject,
                "GiftVsDeposit",
                "ran",
                string.concat(
                    "deposit N/A (",
                    depositNote,
                    "); gift=",
                    LiveReport.qty(size, dec),
                    " taBefore=",
                    LiveReport.qty(ta0, dec),
                    " taAfter=",
                    LiveReport.qty(ta1, dec),
                    " priceBefore=",
                    LiveReport.u(price0),
                    " priceAfter=",
                    LiveReport.u(price1)
                ),
                counts ? "gifts counted (deposit gated)" : "gifts not counted at pin (deposit gated)",
                "none named"
            );
            return;
        }

        uint256 taBefore = vault.totalAssets();
        uint256 priceBefore = _pricePerShare(vault);
        (bool giftMoved, string memory giftErr) = _attemptGift(asset, gifter, address(vault), size);
        if (!giftMoved) {
            LiveReport.row(
                subject,
                "GiftVsDeposit",
                "N/A",
                string.concat("deposit ok; gift transfer failed: ", giftErr),
                "N/A (gift transfer failed)",
                "none named"
            );
            return;
        }

        uint256 taAfter = vault.totalAssets();
        uint256 priceAfter = _pricePerShare(vault);
        bool countsGift = taAfter != taBefore || priceAfter != priceBefore;
        LiveReport.row(
            subject,
            "GiftVsDeposit",
            "ran",
            string.concat(
                "deposit ok; gift=",
                LiveReport.qty(size, dec),
                " taBefore=",
                LiveReport.qty(taBefore, dec),
                " taAfter=",
                LiveReport.qty(taAfter, dec),
                " priceBefore=",
                LiveReport.u(priceBefore),
                " priceAfter=",
                LiveReport.u(priceAfter)
            ),
            countsGift ? "gifts counted" : "gifts not counted at pin",
            countsGift ? "later depositors pay higher price; existing LPs gain (not theft)" : "none named"
        );
    }

    function _attemptDeposit(IERC4626 vault, address asset, address depositor, uint256 size)
        internal
        returns (bool ok, string memory note)
    {
        uint256 maxDep = 0;
        try vault.maxDeposit(depositor) returns (uint256 m) {
            maxDep = m;
        } catch {}
        if (maxDep == 0) return (false, "maxDeposit=0");

        uint256 depAmt = size > maxDep ? maxDep : size;
        vm.startPrank(depositor);
        IERC20(asset).approve(address(vault), type(uint256).max);
        try vault.deposit(depAmt, depositor) returns (uint256) {
            ok = true;
        } catch Error(string memory reason) {
            note = string.concat("deposit revert: ", reason);
        } catch (bytes memory data) {
            note = string.concat("deposit revert bytes=", _bytesPreview(data));
        }
        vm.stopPrank();
    }

    function _attemptGift(address asset, address gifter, address vault, uint256 size)
        internal
        returns (bool ok, string memory err)
    {
        vm.startPrank(gifter);
        try IERC20(asset).transfer(vault, size) {
            ok = true;
        } catch Error(string memory reason) {
            err = string.concat("gift transfer revert: ", reason);
        } catch (bytes memory data) {
            err = string.concat("gift transfer revert bytes=", _bytesPreview(data));
        }
        vm.stopPrank();
    }

    function _casePreviewVsActual(
        string memory subject,
        IERC4626 vault,
        address asset,
        uint256 size,
        uint8 dec
    ) internal {
        address actor = makeAddr(string.concat("prev-", subject));
        if (!_fund(asset, actor, size * 4)) {
            LiveReport.row(subject, "PreviewVsActual", "N/A", "deal(asset) failed", "N/A (deal failed)", "none named");
            return;
        }

        uint256 maxDep = 0;
        try vault.maxDeposit(actor) returns (uint256 m) {
            maxDep = m;
        } catch {}
        if (maxDep == 0) {
            LiveReport.row(subject, "PreviewVsActual", "N/A", "maxDeposit=0", "N/A gated", "none named");
            return;
        }

        uint256 depAmt = size > maxDep ? maxDep : size;
        uint256 previewDep;
        try vault.previewDeposit(depAmt) returns (uint256 p) {
            previewDep = p;
        } catch Error(string memory reason) {
            LiveReport.row(subject, "PreviewVsActual", "N/A", string.concat("previewDeposit revert: ", reason), "N/A gated", "none named");
            return;
        } catch (bytes memory data) {
            LiveReport.row(
                subject,
                "PreviewVsActual",
                "N/A",
                string.concat("previewDeposit revert bytes=", _bytesPreview(data)),
                "N/A gated",
                "none named"
            );
            return;
        }

        vm.startPrank(actor);
        IERC20(asset).approve(address(vault), type(uint256).max);
        uint256 actualDep;
        bool ok;
        string memory err;
        try vault.deposit(depAmt, actor) returns (uint256 shares) {
            actualDep = shares;
            ok = true;
        } catch Error(string memory reason) {
            err = reason;
        } catch (bytes memory data) {
            err = _bytesPreview(data);
        }
        vm.stopPrank();

        if (!ok) {
            LiveReport.row(
                subject,
                "PreviewVsActual",
                "N/A",
                string.concat("deposit revert: ", err, " (maxDeposit was ", LiveReport.u(maxDep), ")"),
                "N/A gated",
                "none named"
            );
            return;
        }

        bool depPass = actualDep >= previewDep;
        string memory extra = _tryRedeemNote(vault, asset, actor, dec);

        LiveReport.row(
            subject,
            "PreviewVsActual",
            "ran",
            string.concat(
                "deposit assets=",
                LiveReport.qty(depAmt, dec),
                " actualShares=",
                LiveReport.u(actualDep),
                " previewShares=",
                LiveReport.u(previewDep),
                extra
            ),
            depPass ? "PASS (deposit actual>=preview)" : "FAIL (deposit actual<preview)",
            depPass ? "none named" : "integrators / depositors relying on previewDeposit"
        );
    }

    function _tryRedeemNote(IERC4626 vault, address asset, address actor, uint8 dec)
        internal
        returns (string memory extra)
    {
        uint256 sharesBal = IERC20(address(vault)).balanceOf(actor);
        if (sharesBal == 0) return "; redeem N/A (no shares)";
        uint256 redeemShares = sharesBal / 4;
        if (redeemShares == 0) redeemShares = sharesBal;

        uint256 previewRed;
        try vault.previewRedeem(redeemShares) returns (uint256 p) {
            previewRed = p;
        } catch {
            return "; redeem N/A (previewRedeem revert)";
        }

        uint256 assetsBefore = IERC20(asset).balanceOf(actor);
        vm.prank(actor);
        try vault.redeem(redeemShares, actor, actor) returns (uint256 out) {
            uint256 delta = IERC20(asset).balanceOf(actor) - assetsBefore;
            uint256 actualRed = delta > 0 ? delta : out;
            return string.concat(
                "; redeem actual=",
                LiveReport.qty(actualRed, dec),
                " preview=",
                LiveReport.qty(previewRed, dec),
                actualRed >= previewRed ? " OK" : " FAIL"
            );
        } catch {
            return "; redeem N/A (cooldown/gated)";
        }
    }

    function _pricePerShare(IERC4626 vault) internal view returns (uint256) {
        try vault.convertToAssets(1e18) returns (uint256 p) {
            return p;
        } catch {
            uint8 sd = 18;
            try IERC20Metadata(address(vault)).decimals() returns (uint8 d) {
                sd = d;
            } catch {}
            try vault.convertToAssets(10 ** uint256(sd)) returns (uint256 p2) {
                return p2;
            } catch {
                return 0;
            }
        }
    }

    /// @dev Fund with deal. WETH/FRXETH: deal without totalSupply adjust. Fallback: wrap ETH for WETH.
    function _fund(address token, address to, uint256 amount) internal returns (bool) {
        if (token == WETH) {
            deal(to, amount);
            vm.prank(to);
            (bool sent,) = token.call{value: amount}("");
            if (!sent) return false;
            return IERC20(token).balanceOf(to) >= amount;
        }
        // Prefer deal without totalSupply adjust first (friendlier to odd ERC20s).
        deal(token, to, amount);
        if (IERC20(token).balanceOf(to) >= amount) return true;
        deal(token, to, amount, true);
        return IERC20(token).balanceOf(to) >= amount;
    }

    function _bytesPreview(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "empty";
        if (data.length >= 4) {
            bytes4 sel;
            assembly {
                sel := mload(add(data, 0x20))
            }
            return string.concat("sel=", _toHex4(sel), " len=", LiveReport.u(data.length));
        }
        return "len<4";
    }

    function _toHex4(bytes4 sel) internal pure returns (string memory) {
        bytes16 hexSymbols = "0123456789abcdef";
        bytes memory s = new bytes(10);
        s[0] = "0";
        s[1] = "x";
        uint32 v = uint32(sel);
        for (uint256 i = 0; i < 4; i++) {
            uint8 b = uint8(v >> (8 * (3 - i)));
            s[2 + i * 2] = hexSymbols[b >> 4];
            s[3 + i * 2] = hexSymbols[b & 0x0f];
        }
        return string(s);
    }
}
