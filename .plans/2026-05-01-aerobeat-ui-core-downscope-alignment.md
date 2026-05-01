# AeroBeat UI Core Downscope Alignment

**Date:** 2026-05-01  
**Status:** In Progress  
**Agent:** Chip 🐱‍💻

---

## Goal

Align `aerobeat-ui-core` with the downscoped AeroBeat v1 UI/platform truth so the repo no longer implies broader current platform or input parity than the product actually supports.

---

## Overview

After aligning the other shared core surfaces, `aerobeat-ui-core` is the next likely place for stale platform/input assumptions to persist. The approved product truth is now narrower: PC community first, mobile second, VR/XR later; camera is the official v1 gameplay input; mouse/touch remain valid for UI/menu navigation; and future shells/platforms should not be presented as equal current peers.

This repo should preserve UI-core portability without reasserting broad present-tense parity across desktop/mobile/web/XR or across gameplay and navigation input contexts. The audit should identify whether the repo needs only scope-language cleanup or whether deeper shared UI contracts/examples/tests still encode the older worldview.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Active plan for this repo-local cleanup slice | `.plans/2026-05-01-aerobeat-ui-core-downscope-alignment.md` |
| `REF-02` | Updated AeroBeat docs source of truth | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-docs` |
| `REF-03` | Parent coordination plan and matrix | `/home/derrick/.openclaw/workspace/projects/openclaw-chip/.plans/2026-05-01-aerobeat-polyrepo-downscope-audit.md` |
| `REF-04` | Recently aligned feature/input/tool surfaces | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core` |

---

## Tasks

### Task 1: Audit `aerobeat-ui-core` for stale downscope assumptions

**Bead ID:** `aerobeat-ui-core-shy`  
**SubAgent:** `primary`  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Audit this repo against the updated docs and aligned shared core surfaces. Identify stale ui-core assumptions such as broad current platform parity, broad gameplay-input parity inside UI surfaces, or docs/examples/tests/contracts that fail to distinguish desktop-first current scope from future/deprioritized mobile/web/XR paths. Do not edit yet; produce an execution-ready list.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Completed the stale UI-scope audit. Main findings: the actual UI-core base classes are mostly fine, but the repo still has stale repo-positioning language and an unnecessary dev/test dependency on `aerobeat-input-core` that blurs UI/menu navigation concerns with gameplay-input infrastructure. The key coder work for this slice is to remove that stale dependency from the testbed, update the test that enforced it, and tighten README/plugin wording so the repo stays desktop-first/current and portable without implying broad platform or gameplay-input parity. Setup warned that origin already has a beads database and `bd bootstrap` would be the correct clone path, but the local cleanup slice is proceeding on a fresh local Beads database for now.

---

### Task 2: Apply the repo cleanup and scope alignment

**Bead ID:** `aerobeat-ui-core-0zo`  
**SubAgent:** `primary`  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** After the audit/action list is approved, update this repo so its shared ui-core contracts, docs, examples, and tests match the downscoped AeroBeat v1 UI/platform truth. Commit and push by default.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ✅ Complete

**Results:** Applied the downscope UI-scope alignment. The coder pass removed the stale `aerobeat-input-core` dependency from `.testbed/addons.jsonc`, replaced the old dependency-enforcement test in `.testbed/tests/test_ui_core_base_classes.gd` with a regression that verifies the hidden testbed stays decoupled from gameplay-input addons while still declaring GUT, tightened `README.md` around desktop/PC-first current shells plus future/deprioritized mobile/web/XR, and narrowed `plugin.cfg` metadata wording so it no longer implies broad platform parity or gameplay-input coupling. `scripts/base/aero_view_base.gd` did not need changes. Validation passed after installing testbed deps/importing resources and running the GUT suite. Changes were committed/pushed as `376d122` (`Align ui-core with downscoped UI scope`). The untracked `.plans/` file was intentionally left out of the coder commit.

---

### Task 3: QA and audit the alignment

**Bead ID:** `aerobeat-ui-core-8ub` (QA), `aerobeat-ui-core-02c` (Auditor)  
**SubAgent:** `primary`  
**Role:** `qa` then `auditor`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`  
**Prompt:** Independently verify that this repo reflects desktop-first current scope, future/deprioritized mobile/web/XR framing, and the gameplay-vs-navigation input distinction without reasserting old parity assumptions.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `docs/`
- `src/`
- `tests/`

**Files Created/Deleted/Modified:**
- `.plans/2026-05-01-aerobeat-ui-core-downscope-alignment.md`
- `docs/**`
- `src/**`
- `tests/**`

**Status:** ⏳ In Progress

**Results:** QA pass completed with no fixes required and recommended auditor handoff. QA confirmed that `aerobeat-ui-core` no longer teaches a foundational dependency on `aerobeat-input-core`, that README now clearly states desktop/PC-first current priority with mobile/web/XR future/deprioritized, that gameplay input is separated from UI/menu-layer concerns, and that `.testbed/addons.jsonc` now declares only GUT while `.testbed/tests/test_ui_core_base_classes.gd` enforces decoupling rather than coupling. The repo-local GUT suite passed 4/4.

---

## Final Results

**Status:** ⚠️ Partial

**What We Built:** Draft repo-local plan for the next shared UI-scope cleanup slice.

**Reference Check:** Pending repo audit and execution.

**Commits:**
- None yet.

**Lessons Learned:** Shared UI-core abstractions need to preserve portability without quietly reintroducing broad present-tense platform or input parity.

---

*Completed on 2026-05-01*