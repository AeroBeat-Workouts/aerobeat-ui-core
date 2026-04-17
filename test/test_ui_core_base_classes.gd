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

func test_tagged_core_dependency_is_restored_into_testbed_addons() -> void:
	assert_true(
		FileAccess.file_exists("res://addons/aerobeat-core/plugin.cfg"),
		"The tagged aerobeat-core dependency should restore into the GodotEnv-managed testbed addons folder"
	)
