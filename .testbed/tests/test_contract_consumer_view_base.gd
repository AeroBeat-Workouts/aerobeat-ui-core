extends GutTest

const VIEW_SCRIPT := preload("res://scripts/base/aero_contract_consumer_view_base.gd")
const BINDING_SCRIPT := preload("res://scripts/contract/aero_ui_contract_target_binding.gd")


func test_binding_owns_interactable_and_listener() -> void:
	var root := Control.new()
	add_child_autofree(root)

	var control := Button.new()
	control.name = "ProofButton"
	root.add_child(control)

	var binding := BINDING_SCRIPT.new() as AeroUiContractTargetBinding
	binding.target_key = "proof"
	binding.set_target_label("ProofButton")
	root.add_child(binding)
	await get_tree().process_frame
	binding.bind_to_control(control)

	assert_not_null(binding.interactable, "Binding should create one interactable")
	assert_not_null(binding.listener, "Binding should create one listener")
	assert_eq(String(binding.get_target_path()), String(control.get_path()), "Binding should track the control path")
	assert_eq(String(binding.interactable.target_path_filter), String(control.get_path()), "Interactable filter should target the bound control")
	assert_eq(String(binding.listener.target_path_filter), String(control.get_path()), "Listener filter should target the bound control")


func test_consumer_view_registers_targets_and_exports_specs() -> void:
	var view := VIEW_SCRIPT.new() as AeroContractConsumerViewBase
	view.interaction_surface_id = &"test_surface"
	add_child_autofree(view)
	await get_tree().process_frame

	var primary := Button.new()
	primary.name = "Primary"
	primary.position = Vector2(20.0, 30.0)
	primary.size = Vector2(120.0, 48.0)
	view.add_child(primary)

	var chip := Button.new()
	chip.name = "Chip"
	chip.position = Vector2(180.0, 30.0)
	chip.size = Vector2(88.0, 42.0)
	view.add_child(chip)
	await get_tree().process_frame

	var primary_binding := view.register_contract_target("primary", primary, {"target_label": "Primary", "user_state": {"toggle_on": false}})
	var chip_binding := view.register_contract_target("chip", chip, {"target_label": "Chip", "user_state": {"toggle_on": true}})

	assert_not_null(primary_binding, "Primary binding should register")
	assert_not_null(chip_binding, "Chip binding should register")

	var specs := view.get_interaction_target_specs()
	assert_eq(specs.size(), 2, "View should export one target spec per registered control")
	assert_eq(view.get_target_key_for_path(primary_binding.get_target_path()), "primary", "Path lookup should map back to the primary key")
	assert_true(bool(view._target_states["chip"].get("toggle_on", false)), "User state should merge into the aggregated target snapshot")
