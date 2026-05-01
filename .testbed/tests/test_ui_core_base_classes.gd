extends GutTest

func test_aero_view_base_is_a_control() -> void:
	var script := load("res://scripts/base/aero_view_base.gd")
	assert_not_null(script, "AeroViewBase script should load from the testbed project")

	var view = script.new()
	assert_true(view is Control, "AeroViewBase should provide a reusable Control-based UI contract")
	view.free()

func test_aero_button_base_is_a_button() -> void:
	var script := load("res://scripts/base/aero_button_base.gd")
	assert_not_null(script, "AeroButtonBase script should load from the testbed project")

	var button = script.new()
	assert_true(button is Button, "AeroButtonBase should provide a reusable Button-based UI contract")
	button.free()

func test_testbed_manifest_stays_decoupled_from_gameplay_input_addons() -> void:
	var addons_manifest := FileAccess.get_file_as_string("res://addons.jsonc")
	assert_ne(addons_manifest, "", "The testbed addons manifest should remain readable from the hidden workbench")
	assert_eq(
		addons_manifest.find("\"aerobeat-input-core\""),
		-1,
		"UI core's hidden testbed should not require gameplay-input addons to validate its shared base-class contract"
	)
	assert_ne(
		addons_manifest.find("\"gut\""),
		-1,
		"The hidden testbed should continue declaring GUT for repo-local validation"
	)
