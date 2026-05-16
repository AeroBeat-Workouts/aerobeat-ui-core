# AeroBeat UI Core — UI Contract Consumer Extraction

**Date:** 2026-05-15  
**Status:** Draft  
**Agent:** Byte 🐈‍⬛

---

## Goal

Extract the reusable UI-facing contract-consumption layer from `aerobeat-ui-kit-community` into `aerobeat-ui-core`, so shared AeroBeat views can consume `aerobeat-input-core` through stable target-binding and multi-target consumer/controller helpers without pulling host routing/projection logic into UI core.

---

## Overview

The current `aerobeat-ui-kit-community` work has now proven the input contract seam in three meaningful contexts: hybrid single-target, screen-space 2D, and multi-target hybrid routing stress. That is enough repetition to identify a real reusable layer above `aerobeat-input-core`: not the host-side hit/projection logic, but the UI-side pattern for binding one or more target views to `AeroUiInteractionBus`, `AeroUiInteractable`, and `AeroUiInteractionListener`, tracking normalized state, and exposing that state to visuals. Right now that pattern lives mostly inside `glass_shader_panel_source.gd`, which is doing double duty as both a demo view and a contract-state engine.

`aerobeat-ui-core` is the correct home for that reusable consumer-side layer. This repo already exists to hold shared UI logic contracts and non-themed base classes, and it should own portable UI-facing helpers that sit between raw input-core contracts and themed/community views. The extraction should therefore focus on reusable target-binding and multi-target view/controller helpers: contract-aware view plumbing that can be reused across shells without depending on hybrid world-space math, glass-specific visuals, or testbed-only authored layouts.

The key boundary must stay clean. `aerobeat-input-core` continues to own event semantics, adapters, bus, interactables, and listeners. `aerobeat-ui-core` should own higher-level UI consumption helpers built on top of that. `aerobeat-ui-kit-community` should keep host-specific input publishing, target lookup, world-space projection, and themed proof scenes. This plan is about moving only the layer that has actually proven reusable.

---

## REFERENCES

| ID | Description | Path |
| --- | --- | --- |
| `REF-01` | Current UI core base button class | `scripts/base/aero_button_base.gd` |
| `REF-02` | Current UI core base view class | `scripts/base/aero_view_base.gd` |
| `REF-03` | Current UI core scope/README | `README.md` |
| `REF-04` | Input-core contract rollout doc | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md` |
| `REF-05` | Hybrid input-core adoption plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-15-input-core-adoption-for-hybrid-ui.md` |
| `REF-06` | Screen-space 2D adoption plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-15-input-core-adoption-for-screen-2d-ui.md` |
| `REF-07` | Multi-target hybrid stress plan/results | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.plans/2026-05-15-multi-target-hybrid-input-stress.md` |
| `REF-08` | Current shared panel source implementation to mine for reusable patterns | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_panel_source.gd` |
| `REF-09` | Current hybrid host implementation (should mostly stay out of ui-core) | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_gui_3d_test.gd` |
| `REF-10` | Current screen 2D host implementation (should mostly stay out of ui-core) | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community/.testbed/scripts/glass_shader_test.gd` |

---

## Tasks

### Task 1: Design the extraction boundary and proposed UI-core helper surface

**Bead ID:** `aerobeat-ui-core-1gb`  
**SubAgent:** `primary` (for `research` workflow role)  
**Role:** `research`  
**References:** `REF-01`, `REF-02`, `REF-03`, `REF-04`, `REF-05`, `REF-06`, `REF-07`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core`, design the clean extraction boundary for the reusable UI-facing contract-consumer layer. Be explicit about what should move from `glass_shader_panel_source.gd` into `ui-core`, what should stay in `ui-kit-community`, what should remain in `input-core`, and what the proposed helper/API surface should look like for per-target binding and multi-target contract-driven views.

**Folders Created/Deleted/Modified:**
- `.plans/`
- `scripts/`
- optional `docs/` if useful

**Files Created/Deleted/Modified:**
- optional design/extraction note

**Status:** ✅ Complete

**Results:** Design concluded that the reusable UI-facing contract-consumer layer should move into `aerobeat-ui-core` while keeping `AeroUiInteractionBus`, event semantics, adapters, `AeroUiInteractable`, and `AeroUiInteractionListener` in `aerobeat-input-core`, and keeping host routing/projection logic in `aerobeat-ui-kit-community`. The approved extracted surface consists of a per-target binding helper (`AeroUiContractTargetBinding`) plus a multi-target consumer/view base (`AeroContractConsumerViewBase`) that own target registration, bus/surface/path filter plumbing, aggregated target state, and `get_interaction_target_specs()` export. Design note written to `docs/notes/2026-05-15-ui-contract-consumer-extraction-design.md`.

---

### Task 2: Implement the extracted UI-core helpers and adopt them in ui-kit-community

**Bead ID:** `aerobeat-ui-core-3ge`  
**SubAgent:** `primary` (for `coder` workflow role)  
**Role:** `coder`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-08`  
**Prompt:** In `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-core`, implement the approved reusable UI-facing contract helpers (for example per-target binding and/or multi-target consumer/controller helpers), and then update `aerobeat-ui-kit-community` to consume them instead of owning all target-state bookkeeping inside `glass_shader_panel_source.gd`. Keep host routing/projection logic out of `ui-core`.

**Folders Created/Deleted/Modified:**
- `scripts/`
- optional `.testbed/` if repo-local proof is useful
- corresponding consumer files in `aerobeat-ui-kit-community`

**Files Created/Deleted/Modified:**
- new helper files in `aerobeat-ui-core`
- updated usage in `aerobeat-ui-kit-community`
- docs/tests as needed

**Status:** ✅ Complete

**Results:** The reusable UI-facing contract-consumer layer was extracted into `aerobeat-ui-core` and adopted in `aerobeat-ui-kit-community`. In `aerobeat-ui-core`, commit `b5c6222` (`Extract UI contract consumer base layer`) added `scripts/contract/aero_ui_contract_target_binding.gd` (`AeroUiContractTargetBinding`) and `scripts/base/aero_contract_consumer_view_base.gd` (`AeroContractConsumerViewBase`), plus test coverage in `.testbed/tests/test_contract_consumer_view_base.gd`. The new helpers now own per-target interactable/listener pairs, bus-path and surface-id injection, target-path filter wiring, target registry/order, aggregated target state snapshots, and `get_interaction_target_specs()` export for host lookup. In `aerobeat-ui-kit-community`, commit `fdc5fa2` (`Adopt extracted UI contract consumer layer`) pinned `.testbed/addons.jsonc` to the new `aerobeat-ui-core` commit and refactored `.testbed/scripts/glass_shader_panel_source.gd` to extend `AeroContractConsumerViewBase`, register primary/chip/strip targets through the shared helpers, and keep only view-specific behavior such as toggle logic, strip progress updates, and summary/debug label rendering. Host routing/projection logic remained in `glass_shader_gui_3d_test.gd` and `glass_shader_test.gd` as intended. Coder-reported validation passed in both repos; one older temporary QA probe in `ui-kit-community` still assumes the pre-extraction direct-child consumer layout and needs updating, but the actual adoption behavior probe passed.

---

### Task 3: QA the extraction for correctness, portability, and boundary cleanliness

**Bead ID:** `aerobeat-ui-core-7r2`  
**SubAgent:** `primary` (for `qa` workflow role)  
**Role:** `qa`  
**References:** `REF-04`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** Verify that the extracted helpers in `aerobeat-ui-core` are actually reusable, that `ui-kit-community` still behaves correctly after adopting them, and that host routing/projection logic did not leak upward into `ui-core`.

**Folders Created/Deleted/Modified:**
- QA artifact paths if useful

**Files Created/Deleted/Modified:**
- QA evidence artifacts if produced

**Status:** ✅ Complete

**Results:** QA passed with one explicit caveat about stale QA artifact drift, not a product regression. QA confirmed that `aerobeat-ui-core` now really owns reusable helpers (`AeroUiContractTargetBinding` and `AeroContractConsumerViewBase`) and that they hold the intended responsibilities: per-target interactable/listener creation, bus-path and surface-id injection, target-path filter wiring, aggregated target-state registry/lookup, and `get_interaction_target_specs()` export. In `aerobeat-ui-kit-community`, `glass_shader_panel_source.gd` now consumes those helpers through `_build_contract_targets()` and no longer owns the raw target-binding plumbing directly, while host routing/projection logic remains in `glass_shader_gui_3d_test.gd` and `glass_shader_test.gd`. Repo-local validation passed in both repos (imports, GUT suites, `git diff --check`), and an updated adoption validator confirmed both screen and hybrid scenes now expose three binding nodes and three target specs. The only caveat is that one older temporary QA probe still assumes the pre-extraction direct-child consumer layout and now fails for that stale reason; newer validation aligned to the binding-owned layout passed.

---

### Task 4: Audit whether the new UI-core layer is the right long-term ownership home

**Bead ID:** `aerobeat-ui-core-rcf`  
**SubAgent:** `primary` (for `auditor` workflow role)  
**Role:** `auditor`  
**References:** `REF-01`, `REF-02`, `REF-04`, `REF-08`, `REF-09`, `REF-10`  
**Prompt:** Audit the extraction independently. Decide whether the moved helper layer genuinely belongs in `aerobeat-ui-core`, whether the remaining code in `ui-kit-community` is the right residue, and whether the `input-core` / `ui-core` / `ui-kit-community` boundary is now cleaner than before.

**Folders Created/Deleted/Modified:**
- `.plans/` (notes/results only if needed)

**Files Created/Deleted/Modified:**
- optional audit notes if produced

**Status:** ✅ Complete

**Results:** Audit passed with one non-blocking cleanup requirement that has since been addressed in `aerobeat-ui-kit-community`: stale temporary QA probes were updated to the binding-owned layout so they no longer produce false negatives. The audit confirmed that `aerobeat-ui-core` is the correct long-term ownership home for this helper layer, that the `input-core` / `ui-core` / `ui-kit-community` boundary is meaningfully cleaner than before, and that the extraction was neither too early nor the wrong slice. This boundary is now good enough for broader reusable AeroBeat UI contract-consumer work without another seam redesign.

---

## Final Results

**Status:** ✅ Complete

**What We Built:** Extracted a reusable UI-facing contract-consumer layer into `aerobeat-ui-core` (`AeroUiContractTargetBinding` + `AeroContractConsumerViewBase`) and adopted it in `aerobeat-ui-kit-community`, where `glass_shader_panel_source.gd` now consumes shared helpers instead of hand-owning target binding plumbing.

**Reference Check:** `input-core` still owns event semantics/adapters/core consumers; `ui-core` now owns reusable UI-side target binding and multi-target consumer state; `ui-kit-community` still owns host routing/projection logic and themed proof scenes. The intended repo boundary is cleaner and preserved.

**Commits:**
- `b5c6222` - Extract UI contract consumer base layer
- `fdc5fa2` - Adopt extracted UI contract consumer layer

**Lessons Learned:** Wait to extract until the consumer-side pattern has repeated across at least a hybrid proof, a simpler screen-space proof, and a routing-stress proof. That gave enough confidence to move only the stable UI-facing layer without prematurely lifting host math or input semantics into the wrong repo.

---

*Drafted on 2026-05-15*