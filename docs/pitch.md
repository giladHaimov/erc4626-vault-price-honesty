# ERC-4626 vault test report (Foundry)

I am not shipping a patched vault. OpenZeppelin already documented leftover-empty and donation. After the last share is gone you can get fewer new shares and still redeem about the same tokens. “The depositor was cheated / I fixed OZ” is the wrong claim. A senior asks who lost money. Often nobody did.

What still bites teams is **composability**: `preview*` vs the real call, a share price that jumps, a fee or oracle that treats that jump as yield. Sometimes the pot is not even in the vault — it sits in Aave-like helpers — and there is no honest on-chain “fix” for a number you do not control. So I do not sell a cure. I ship a **Foundry suite that measures a 4626 and writes a vault test report** (not an audit).

## What it does

Default path is a **mainnet fork at a pinned block**. Mocks only if `deposit` is gated and we cannot drive the real contract.

**Local fixtures first** (required): one boring-correct vault, plus a few vaults with planted faults. That proves the tool catches real faults and does not accuse clean code. Forks are the demo, not the proof the tool works.

Then the same cases on **10–15 live vaults** (number fixed up front). One vault is a demo. A table of fifteen is a study. Each case is marked **ran / not applicable** and why. I will not storage-zero a live pot and call that “the protocol can go empty.”

Gift vs official add needs no source: call `deposit()`, then `transfer` the same token to the vault. If `totalAssets` or price moves on the transfer, they count gifts.

## Cases (order is the point)

1. **Preview vs actual** — strongest. The spec is directional, not `==`: for `deposit`/`redeem` you must get at least the preview; for `mint`/`withdraw` you must not pay more than the preview. Check all four, plus balances, in the same tx. A live fail here is a spec break, not a vibe.
2. **Leftover empty** — shares = 0, ERC-20 still on the vault. Report share *count*, redeem *value*, and whether price jumped.
3. **Gift** — unofficial `transfer` vs `deposit`.
4. **First-depositor inflation** — the famous empty donation. Included so it is not forgotten.
5. **Helper gap** — only if we can decode that position. “`totalAssets` ≠ `balanceOf(vault)`” is usually architecture, not a finding. A gap that **opens and closes over time** is the measurable risk. If we cannot decode: **not enough data**, not “helper lie.”

## The report

Markdown table. Facts first: before/after numbers, spec pass/fail, ran/N/A.

**One judgment column:** if this number moved, **who is hurt** — not “vulnerable/safe.” Example: price 2× with no yield → any performance fee on share price charges profit that did not happen. If I cannot name a victim, I do not invent one. A price jump alone is not a fee bug; I only claim a fee/oracle break if I show that path.

No “exhaustive.” No “best route.” No adapter fairy tale. No AI/DAO.

**Time:** 2–3 weeks. Product is `test/` + the report. Tiny fixture vaults only.

I measure 4626 pots. I don’t sell a cure. I do say who gets hurt when I can prove it.
