@tool
class_name AeroContractConsumerViewBase
extends AeroViewBase

var interaction_bus_path: NodePath = NodePath()
var interaction_surface_id: StringName = &""
var interaction_surface_type_label := ""
var contract_host_summary := ""
var contract_mode_label := ""

var _interaction_bus_path_override: NodePath = NodePath()
var _contract_target_bindings_by_key: Dictionary = {}
var _contract_target_binding_order: Array = []
var _target_states: Dictionary = {}
var _path_to_target_key: Dictionary = {}


func _ready() -> void:
	_build_contract_targets()
	refresh_contract_bindings()


func set_interaction_bus_path(bus_path: NodePath) -> void:
	_interaction_bus_path_override = bus_path
	interaction_bus_path = bus_path
	refresh_contract_bindings()


func configure_interaction_contract(config: Dictionary) -> void:
	if config.has("surface_id"):
		interaction_surface_id = StringName(config["surface_id"])
	if config.has("surface_type_label"):
		interaction_surface_type_label = str(config["surface_type_label"])
	if config.has("host_summary"):
		contract_host_summary = str(config["host_summary"])
	if config.has("mode_label"):
		contract_mode_label = str(config["mode_label"])
	if config.has("interaction_bus_path"):
		set_interaction_bus_path(config["interaction_bus_path"])
	else:
		refresh_contract_bindings()


func register_contract_target(target_key: String, control: Control, options: Dictionary = {}) -> AeroUiContractTargetBinding:
	var binding := get_contract_target_binding(target_key)
	if binding == null:
		binding = AeroUiContractTargetBinding.new()
		binding.target_key = target_key
		binding.name = "%sContractBinding" % target_key.capitalize()
		add_child(binding)
		_contract_target_bindings_by_key[target_key] = binding
		_contract_target_binding_order.append(binding)
		binding.interaction_event.connect(_on_contract_binding_interaction_event)
		binding.hovered_changed.connect(_on_contract_binding_hovered_changed)
		binding.pressed_changed.connect(_on_contract_binding_pressed_changed)
		binding.dragging_changed.connect(_on_contract_binding_dragging_changed)
		binding.tapped.connect(_on_contract_binding_tapped)
		binding.canceled.connect(_on_contract_binding_canceled)
		binding.state_changed.connect(_on_contract_binding_state_changed)

	binding.target_key = target_key
	binding.set_target_label(str(options.get("target_label", control.name if is_instance_valid(control) else target_key)))
	binding.user_state = (options.get("user_state", {}) as Dictionary).duplicate(true)
	binding.bind_to_control(control)
	binding.set_surface_id(interaction_surface_id)
	binding.set_pointer_id_filter(StringName(options.get("pointer_id_filter", binding.pointer_id_filter)))
	_sync_target_state_snapshot(binding)
	refresh_contract_bindings()
	return binding


func get_contract_target_binding(target_key: String) -> AeroUiContractTargetBinding:
	return _contract_target_bindings_by_key.get(target_key) as AeroUiContractTargetBinding


func get_contract_target_bindings() -> Array:
	return _contract_target_binding_order.duplicate()


func get_interaction_target_specs() -> Array:
	var specs: Array = []
	for binding_variant in _contract_target_binding_order:
		var binding := binding_variant as AeroUiContractTargetBinding
		if binding == null:
			continue
		var spec := binding.get_target_spec()
		if spec.get("target_path", NodePath()) == NodePath():
			continue
		specs.append(spec)
	return specs


func get_target_key_for_path(target_path: NodePath) -> String:
	return str(_path_to_target_key.get(str(target_path), ""))


func refresh_contract_bindings() -> void:
	var bus := _resolve_interaction_bus()
	var bus_path := bus.get_path() if is_instance_valid(bus) else _resolve_interaction_bus_path_hint()
	for binding_variant in _contract_target_binding_order:
		var binding := binding_variant as AeroUiContractTargetBinding
		if binding == null:
			continue
		if not is_instance_valid(binding.control) and binding.control_path != NodePath():
			binding.bind_to_control(get_node_or_null(binding.control_path) as Control)
		binding.set_surface_id(interaction_surface_id)
		binding.set_bus_path(bus_path)
		binding.connect_to_bus(bus)
		_sync_target_state_snapshot(binding)


func reset_contract_runtime_state() -> void:
	for binding_variant in _contract_target_binding_order:
		var binding := binding_variant as AeroUiContractTargetBinding
		if binding == null:
			continue
		binding.reset_runtime_state()
		_sync_target_state_snapshot(binding)


func _notify_contract_target_state_changed(binding: AeroUiContractTargetBinding) -> void:
	if binding == null:
		return
	_sync_target_state_snapshot(binding)
	_on_contract_target_state_changed(binding)


func _resolve_interaction_bus() -> AeroUiInteractionBus:
	var override_bus := get_node_or_null(_interaction_bus_path_override) as AeroUiInteractionBus if _interaction_bus_path_override != NodePath() else null
	if override_bus != null:
		return override_bus

	var configured_bus := get_node_or_null(interaction_bus_path) as AeroUiInteractionBus if interaction_bus_path != NodePath() else null
	if configured_bus != null:
		return configured_bus

	var default_bus_path := _get_default_interaction_bus_path()
	if default_bus_path != NodePath():
		var fallback_bus := get_node_or_null(default_bus_path) as AeroUiInteractionBus
		if fallback_bus != null:
			return fallback_bus

	var ancestor: Node = self
	while ancestor != null:
		var bus := ancestor.get_node_or_null(_get_interaction_bus_node_path()) as AeroUiInteractionBus
		if bus != null:
			return bus
		ancestor = ancestor.get_parent()
	return null


func _resolve_interaction_bus_path_hint() -> NodePath:
	if _interaction_bus_path_override != NodePath():
		return _interaction_bus_path_override
	if interaction_bus_path != NodePath():
		return interaction_bus_path
	return _get_default_interaction_bus_path()


func _sync_target_state_snapshot(binding: AeroUiContractTargetBinding) -> void:
	if binding == null:
		return

	var target_path := binding.get_target_path()
	var control := binding.control
	var state := {
		"control": control,
		"binding": binding,
		"interactable": binding.interactable,
		"listener": binding.listener,
		"target_path": target_path,
		"hovered": binding.is_hovered,
		"pressed": binding.is_pressed,
		"dragging": binding.is_dragging,
		"press_count": binding.press_count,
		"release_count": binding.release_count,
		"drag_count": binding.drag_count,
		"tap_count": binding.tap_count,
		"last_event": binding.last_event,
		"last_source_variant": str(binding.last_event.source_variant) if binding.last_event != null else "waiting",
		"target_name": binding.target_label,
		"target_key": binding.target_key,
	}
	for key in binding.user_state.keys():
		state[key] = binding.user_state[key]
	_target_states[binding.target_key] = state

	for existing_path_text in _path_to_target_key.keys():
		if _path_to_target_key[existing_path_text] == binding.target_key and existing_path_text != str(target_path):
			_path_to_target_key.erase(existing_path_text)
	if target_path != NodePath():
		_path_to_target_key[str(target_path)] = binding.target_key


func _on_contract_binding_interaction_event(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_interaction(binding, event)


func _on_contract_binding_hovered_changed(binding: AeroUiContractTargetBinding, is_hovered: bool, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_hovered_changed(binding, is_hovered, event)


func _on_contract_binding_pressed_changed(binding: AeroUiContractTargetBinding, is_pressed: bool, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_pressed_changed(binding, is_pressed, event)


func _on_contract_binding_dragging_changed(binding: AeroUiContractTargetBinding, is_dragging: bool, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_dragging_changed(binding, is_dragging, event)


func _on_contract_binding_tapped(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_tapped(binding, event)


func _on_contract_binding_canceled(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_canceled(binding, event)


func _on_contract_binding_state_changed(binding: AeroUiContractTargetBinding) -> void:
	_sync_target_state_snapshot(binding)
	_on_contract_target_state_changed(binding)


func _build_contract_targets() -> void:
	pass


func _on_contract_target_interaction(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_hovered_changed(binding: AeroUiContractTargetBinding, is_hovered: bool, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_pressed_changed(binding: AeroUiContractTargetBinding, is_pressed: bool, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_dragging_changed(binding: AeroUiContractTargetBinding, is_dragging: bool, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_tapped(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_canceled(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent) -> void:
	pass


func _on_contract_target_state_changed(binding: AeroUiContractTargetBinding) -> void:
	pass


func _get_default_interaction_bus_path() -> NodePath:
	return NodePath()


func _get_interaction_bus_node_path() -> NodePath:
	return ^"AeroUiInteractionBus"
