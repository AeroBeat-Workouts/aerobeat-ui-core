extends GutTest

func test_testbed_project_title_is_ui_core_specific() -> void:
	assert_eq(
		ProjectSettings.get_setting("application/config/name"),
		"AeroBeat UI Core Testbed",
		"The hidden workbench should identify itself as the UI core testbed"
	)
