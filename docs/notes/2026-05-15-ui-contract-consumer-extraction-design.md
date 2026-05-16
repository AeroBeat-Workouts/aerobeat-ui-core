# UI-Core Contract Consumer Extraction Design

**Date:** 2026-05-15  
**Repo:** `aerobeat-ui-core`  
**Status:** Research/design only — no implementation in this note

## Goal

Define the clean reusable boundary for the UI-facing contract-consumer layer that now exists implicitly in `aerobeat-ui-kit-community`, and identify what should move into `aerobeat-ui-core` without pulling host routing/projection logic out of the host repo.

## Short conclusion

The reusable seam is **not** the host-side input publishing path. The reusable seam is the **UI-side contract consumption layer**:

- per-target contract binding
- per-target state aggregation above `AeroUiInteractable` / `AeroUiInteractionListener`
- multi-target consumer/view-controller plumbing
- light contract configuration helpers such as bus-path and surface-id injection
- optional target-spec export for host lookup

That layer belongs in `aerobeat-ui-core` because it is shared UI behavior above `aerobeat-input-core`, below any themed/community shell, and now proven across:

- hybrid single-target
- screen-space 2D
- multi-target hybrid stress

## Boundary decision

### Stays in `aerobeat-input-core`

`aerobeat-input-core` continues to own the normalized input contract itself:

- `AeroUiInteractionEvent`
- `AeroUiInteractionTypes`
- `AeroUiInteractionBus`
- `ScreenUiInputAdapter`
- `HybridSubViewportInputAdapter`
- `XrUiInputAdapter`
- `AeroUiInteractable`
- `AeroUiInteractionListener`
- verification-status truth model
- canonical event phases and payload semantics

Reason: these are transport/contract primitives and must remain the single source of truth.

### Moves into `aerobeat-ui-core`

`aerobeat-ui-core` should own the **consumer orchestration layer** built on top of those primitives:

- target registration and lifecycle
- binding one UI control to one contract target
- creating/wiring one interactable + one listener pair per target
- stable per-target aggregated state and counters
- shared multi-target registry and lookup
- bus/surface config injection into all registered targets
- helper export of target specs for host-side routing
- reusable base class that lets a UI view define targets and react to binding events without re-implementing plumbing

Reason: this is reusable UI logic, not raw input normalization and not host-specific projection/routing.

### Stays in `aerobeat-ui-kit-community`

The following should remain local to `ui-kit-community`:

- world ray picking
- 3D hit testing
- UV / local-hit / viewport projection math
- hover-enter/exit truth when the world ray leaves or re-enters the panel
- pointer capture / owner-path continuity policy
- target-path resolution from projected coordinates
- scene-specific contract status panels for the testbed host
- glass-specific visuals, labels, copy, and shader behavior
- proof-scene layout and manual demo affordances

Reason: those are either host responsibilities or theme/testbed responsibilities, not shared UI-core responsibilities.

## What is actually reusable in `glass_shader_panel_source.gd`

The reusable part of the current script is not the glass look. It is the repeated contract-consumer pattern:

1. choose a set of target `Control`s
2. create one `AeroUiInteractable` + one `AeroUiInteractionListener` per target
3. assign shared `bus_path` and `surface_id_filter`
4. assign each target's `target_path_filter`
5. subscribe to the helper signals
6. maintain target-local state:
   - hovered
   - pressed
   - dragging
   - last event
   - press/release/drag/tap counts
   - optional target-local derived state like toggle/progress
7. expose target rect/path specs back to the host when needed
8. let the actual view script focus on visuals and per-target meaning

That is the exact layer that should be extracted.

## Proposed `ui-core` surface

## Proposed files/classes

### 1. `scripts/contract/aero_ui_contract_target_binding.gd`

**Class:** `AeroUiContractTargetBinding`  
**Type:** lightweight `Node`

### Responsibility

Represents one UI-facing contract target bound to one `Control` and one contract filter path.

It should:

- hold the target key/label/control reference
- create/manage one `AeroUiInteractable`
- create/manage one `AeroUiInteractionListener`
- push shared config into both helpers:
  - bus path
  - surface id
  - target path
  - optional pointer filter
- aggregate stable per-target state/counters
- emit one reusable UI-core level event surface for views
- provide host-facing target spec data

### Proposed public shape

Suggested fields:

- `target_key: String`
- `target_label: String`
- `control_path: NodePath`
- `bus_path: NodePath`
- `surface_id_filter: StringName`
- `pointer_id_filter: StringName`
- `is_hovered: bool`
- `is_pressed: bool`
- `is_dragging: bool`
- `last_event: AeroUiInteractionEvent`
- `press_count: int`
- `release_count: int`
- `drag_count: int`
- `tap_count: int`
- `user_state: Dictionary`

Suggested methods:

- `bind_to_control(control: Control) -> void`
- `set_bus_path(bus_path: NodePath) -> void`
- `set_surface_id(surface_id: StringName) -> void`
- `set_pointer_id_filter(pointer_id: StringName) -> void`
- `set_target_label(label: String) -> void`
- `get_target_path() -> NodePath`
- `get_target_spec() -> Dictionary`
- `reset_runtime_state() -> void`

Suggested signals:

- `interaction_event(binding, event)`
- `hovered_changed(binding, is_hovered, event)`
- `pressed_changed(binding, is_pressed, event)`
- `dragging_changed(binding, is_dragging, event)`
- `tapped(binding, event)`
- `canceled(binding, event)`
- `state_changed(binding)`

### Notes

This is the main thing `glass_shader_panel_source.gd` is manually doing today.

---

### 2. `scripts/base/aero_contract_consumer_view_base.gd`

**Class:** `AeroContractConsumerViewBase`  
**Extends:** `AeroViewBase`

### Responsibility

Reusable multi-target view/controller base for any UI scene that consumes normalized contract events.

It should:

- own the shared interaction contract config for the view
- register and store many `AeroUiContractTargetBinding` instances
- propagate bus path / surface id config to every binding
- provide lookup by target key and by target path
- export target specs for host target resolution
- define a small override surface for themed shells to react to target events

### Proposed public shape

Suggested fields:

- `interaction_bus_path: NodePath`
- `interaction_surface_id: StringName`
- `interaction_surface_type_label: String`
- `contract_host_summary: String`
- `contract_mode_label: String`

Suggested methods:

- `set_interaction_bus_path(bus_path: NodePath) -> void`
- `configure_interaction_contract(config: Dictionary) -> void`
- `register_contract_target(target_key: String, control: Control, options: Dictionary = {}) -> AeroUiContractTargetBinding`
- `get_contract_target_binding(target_key: String) -> AeroUiContractTargetBinding`
- `get_contract_target_bindings() -> Array`
- `get_interaction_target_specs() -> Array`
- `get_target_key_for_path(target_path: NodePath) -> String`
- `refresh_contract_bindings() -> void`
- `reset_contract_runtime_state() -> void`

Suggested protected hooks for subclasses:

- `_build_contract_targets() -> void`
- `_on_contract_target_interaction(binding, event) -> void`
- `_on_contract_target_tapped(binding, event) -> void`
- `_on_contract_target_state_changed(binding) -> void`

### Notes

This base should own the generic target-registry mechanics so actual themed/community views do not have to manually duplicate `_target_states`, `_path_to_target_key`, binding creation, and rebind logic.

---

### 3. Optional: `scripts/contract/aero_ui_contract_target_spec.gd`

**Class:** `AeroUiContractTargetSpec`  
**Type:** optional `RefCounted` or just skip and keep dictionaries

### Recommendation

Skip this in the first extraction unless the implementation really benefits from a dedicated typed object. The current host-facing shape is simple enough as a dictionary:

- `target_key`
- `target_name`
- `target_path`
- `rect`

A dedicated spec class is only worth adding if several repos need stronger typing later.

## Recommended extraction shape

### Minimum useful extraction

Move only the layer that has already repeated enough times to be real:

1. `AeroUiContractTargetBinding`
2. `AeroContractConsumerViewBase`

That is enough to remove the fragile/manual consumer plumbing from `ui-kit-community` while keeping the host code and visuals local.

### Do **not** extract yet

Do not move the following into `ui-core` in this slice:

- any host input adapter wrapper
- any raycast/projection helper
- any screen-vs-hybrid capture policy helper
- any abstract "router" that decides target ownership
- any glass-specific toggle/strip/progress semantics
- any panel-status copy specific to the testbed

Those are either too host-specific or too demo-specific.

## Concrete ownership map for current `glass_shader_panel_source.gd`

### Should move into `ui-core`

From the current script, these concepts should be extracted:

- `_target_states`
- `_path_to_target_key`
- `_setup_contract_consumers()`
- `_register_target_contract(...)`
- `set_interaction_bus_path(...)`
- the **generic part** of `configure_interaction_contract(...)`
- `_bind_contract_consumers_to_runtime_bus()`
- `_resolve_interaction_bus()`
- the generic target-spec export pattern in `get_interaction_target_specs()`
- generic listener/interactable event fan-in into stable target state/counters

### Should stay in `glass_shader_panel_source.gd`

These parts are still view-specific:

- node references for the glass panel scene
- shader parameter APIs
- background/presentation mode APIs
- hybrid shell sync
- label text and debug wording
- primary/chip/drag visual refresh methods
- target-specific semantics:
  - primary card toggles armed state
  - chip toggles secondary state
  - strip maps contract position to progress
- summary/debug presentation layout

### Should stay in host test scripts

In `glass_shader_gui_3d_test.gd` / `glass_shader_test.gd`:

- target-path resolution from projected coordinates or explicit proof-button lookup
- mouse/touch capture decisions
- hover truth when entering/leaving the surface
- projected data assembly
- calls into `ScreenUiInputAdapter` / `HybridSubViewportInputAdapter`
- host-side status/debug panels that explain routing policy

## What `glass_shader_panel_source.gd` should look like after adoption

After extraction, `glass_shader_panel_source.gd` should stop being the place where contract plumbing is invented.

It should instead look conceptually like this:

1. extend `AeroContractConsumerViewBase`
2. keep all current visual node refs and shader/shell methods
3. declare its target keys/labels
4. in `_build_contract_targets()` register:
   - `primary` -> `PrimaryCardButton`
   - `chip` -> `SecondaryToggleChip`
   - `strip` -> `DragStrip`
5. implement only the view-specific reactions:
   - primary tapped => flip primary toggle state
   - chip tapped => flip chip state
   - strip drag => update progress from event position
   - summary labels => render from binding state
6. keep `configure_interaction_contract(...)` only as a thin wrapper for display text/config that calls `super`
7. keep `get_interaction_target_specs()` inherited from base unless this scene needs extra host metadata

### Practical shape

The post-extraction script should mainly contain:

- constants for theme/demo behavior
- `@onready` node references
- shader/background/presentation methods
- a small `_build_contract_targets()` override
- a few target-specific callbacks like:
  - `_on_contract_target_tapped(...)`
  - `_on_contract_target_state_changed(...)`
- visual refresh helpers

It should **not** manually instantiate and wire `AeroUiInteractable` / `AeroUiInteractionListener` for each target anymore.

## Concrete coder-ready adoption plan

### In `aerobeat-ui-core`

Add:

- `scripts/contract/aero_ui_contract_target_binding.gd`
- `scripts/base/aero_contract_consumer_view_base.gd`

Potential README addition:

- a short section describing `ui-core` as the home of reusable UI-facing contract consumers built on top of `aerobeat-input-core`

### In `aerobeat-ui-kit-community`

Update `glass_shader_panel_source.gd` to:

- extend `AeroContractConsumerViewBase`
- replace `_target_states` / `_path_to_target_key` storage with inherited bindings
- replace `_setup_contract_consumers()` and `_register_target_contract(...)` with `_build_contract_targets()` + `register_contract_target(...)`
- replace direct consumer callbacks with base-level target-binding callbacks
- keep all host routing/projection logic untouched in `glass_shader_gui_3d_test.gd` and `glass_shader_test.gd`

## Why this boundary is the right one

This split matches the three current ownership layers cleanly:

- `input-core`: event contract and normalization primitives
- `ui-core`: reusable UI-side consumption and target-binding orchestration
- `ui-kit-community`: themed/demo surfaces and host-specific routing/projection glue

That is the narrowest extraction that:

- captures what has actually repeated
- removes fragile manual plumbing from the testbed view
- avoids dragging host math into UI core
- leaves `input-core` as the canonical source of event semantics

## Explicit out-of-scope items

The following are intentionally out of scope for this extraction:

- moving `AeroUiInteractable` or `AeroUiInteractionListener` out of `input-core`
- moving any adapters out of `input-core`
- moving hybrid/world projection helpers into `ui-core`
- creating a generic host router in `ui-core`
- moving the glass shader demo scene/layout into `ui-core`
- adding keyboard/gamepad navigation abstractions
- adding multi-touch gestures
- changing verification-status truth semantics
- generalizing all demo-specific state labels/copy into shared UI core

## Final recommendation

Implement the extraction in two pieces only:

1. `AeroUiContractTargetBinding`
2. `AeroContractConsumerViewBase`

That gives `ui-core` a real reusable UI-facing contract-consumer layer without violating Derrick's boundary rule: **host routing/projection logic stays out of `ui-core`.**
