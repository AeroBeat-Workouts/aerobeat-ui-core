# aerobeat-ui-core

Shared AeroBeat UI logic contract addon for reusable, non-themed UI base classes consumed by current desktop-first shells and future UI kits.

## Scope stance

`aerobeat-ui-core` keeps shared UI contracts portable, but it does not claim equal present-tense parity across every AeroBeat shell or platform.

- Current priority: desktop/PC community-facing shells
- Future/deprioritized relative to current scope: mobile, web, and XR shells
- Gameplay input is owned elsewhere; this repo stays focused on reusable UI/menu-layer base classes
- Mouse and touch navigation remain valid UI concerns without making gameplay-input infrastructure a foundational dependency here

## GodotEnv development flow

This repo uses the AeroBeat Phase 1 GodotEnv package/foundation convention for its hidden testbed.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

That installs GUT into `.testbed/addons/` for repo-local validation.

### Open the testbed

From the repo root:

```bash
godot --editor --path .testbed
```

The hidden workbench remains the canonical development/debug surface, and repo-local unit tests live under `.testbed/tests/`.

### Validation notes

- `.testbed/addons.jsonc` is the only committed dev/test dependency contract.
- `.testbed/scripts` and `.testbed/tests` are tracked relative links into the repo root. Add `.testbed/scenes` only when the repo needs manual/workbench scene content.
- The public Phase 1 UI contract surface lives under `scripts/base/`.
- The hidden testbed intentionally validates UI-core behavior without teaching a foundational dependency on gameplay-input infrastructure.
