# aerobeat-ui-core

Shared AeroBeat UI logic contract addon for reusable, non-themed UI base classes consumed by UI kits and UI shells.

## GodotEnv development flow

This repo uses the AeroBeat Phase 1 GodotEnv package/foundation convention.

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

That installs the tagged `aerobeat-core` dependency plus GUT into `.testbed/addons/`.

### Open the testbed

From the repo root:

```bash
godot --editor --path .testbed
```

The hidden workbench remains the canonical development/debug surface, and repo-local unit tests now live under `.testbed/tests/`.

### Validation notes

- `.testbed/addons.jsonc` is the only committed dev/test dependency contract.
- `.testbed/scripts` and `.testbed/tests` are tracked relative links into the repo root. Add `.testbed/scenes` only when the repo needs manual/workbench scene content.
- The public Phase 1 UI contract surface lives under `scripts/base/`.
- The manifest pins `aerobeat-core` to `v0.1.0` and restores it from the repo root (`subfolder: "/"`). That repo-root shape is an explicit current-state assumption for the foundational chain, not an implicit wrapper-era artifact.
