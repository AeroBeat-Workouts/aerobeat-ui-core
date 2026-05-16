class_name AeroUiContractTargetBinding
extends Node

signal interaction_event(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent)
signal hovered_changed(binding: AeroUiContractTargetBinding, is_hovered: bool, event: AeroUiInteractionEvent)
signal pressed_changed(binding: AeroUiContractTargetBinding, is_pressed: bool, event: AeroUiInteractionEvent)
signal dragging_changed(binding: AeroUiContractTargetBinding, is_dragging: bool, event: AeroUiInteractionEvent)
signal tapped(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent)
signal canceled(binding: AeroUiContractTargetBinding, event: AeroUiInteractionEvent)
signal state_changed(binding: AeroUiContractTargetBinding)

var target_key := ""
var target_label := ""
var control_path: NodePath = NodePath()
var bus_path: NodePath = NodePath()
var surface_id_filter: StringName = &""
var pointer_id_filter: StringName = &""

var is_hovered := false
var is_pressed := false
var is_dragging := false
var last_event: AeroUiInteractionEvent = null
var press_count := 0
var release_count := 0
var drag_count := 0
var tap_count := 0
var user_state: Dictionary = {}

var control: Control = null
var interactable: AeroUiInteractable = null
var listener: AeroUiInteractionListener = null
var _connected_bus: AeroUiInteractionBus = null


func bind_to_control(next_control: Control) -> void:
	control = next_control
	control_path = control.get_path() if is_instance_valid(control) else NodePath()
	_ensure_consumers()
	_apply_filters_to_consumers()
	_emit_state_changed()


func set_bus_path(next_bus_path: NodePath) -> void:
	bus_path = next_bus_path
	_ensure_consumers()
	if is_instance_valid(interactable):
		interactable.bus_path = bus_path
	if is_instance_valid(listener):
		listener.bus_path = bus_path


func connect_to_bus(bus: AeroUiInteractionBus) -> void:
	if _connected_bus == bus:
		return

	if is_instance_valid(_connected_bus):
		_disconnect_consumer_from_bus(_connected_bus, interactable)
		_disconnect_consumer_from_bus(_connected_bus, listener)

	_connected_bus = bus
	if not is_instance_valid(_connected_bus):
		return

	_connect_consumer_to_bus(_connected_bus, interactable)
	_connect_consumer_to_bus(_connected_bus, listener)


func set_surface_id(surface_id: StringName) -> void:
	surface_id_filter = surface_id
	_apply_filters_to_consumers()


func set_pointer_id_filter(pointer_id: StringName) -> void:
	pointer_id_filter = pointer_id
	_apply_filters_to_consumers()


func set_target_label(label: String) -> void:
	target_label = label
	_update_consumer_names()


func get_target_path() -> NodePath:
	if is_instance_valid(control):
		return control.get_path()
	return control_path


func get_target_spec() -> Dictionary:
	return {
		"target_key": target_key,
		"target_name": target_label,
		"target_path": get_target_path(),
		"rect": control.get_global_rect() if is_instance_valid(control) else Rect2(),
	}


func reset_runtime_state() -> void:
	is_hovered = false
	is_pressed = false
	is_dragging = false
	last_event = null
	press_count = 0
	release_count = 0
	drag_count = 0
	tap_count = 0
	_emit_state_changed()


func _exit_tree() -> void:
	connect_to_bus(null)


func _ensure_consumers() -> void:
	if interactable == null:
		interactable = AeroUiInteractable.new()
		add_child(interactable)
		interactable.interaction_event.connect(_on_interactable_interaction_event)
		interactable.hovered_changed.connect(_on_interactable_hovered_changed)
		interactable.pressed_changed.connect(_on_interactable_pressed_changed)
		interactable.dragging_changed.connect(_on_interactable_dragging_changed)
		interactable.canceled.connect(_on_interactable_canceled)
	if listener == null:
		listener = AeroUiInteractionListener.new()
		add_child(listener)
		listener.interaction_event.connect(_on_listener_interaction_event)
		listener.tapped.connect(_on_listener_tapped)
		listener.canceled.connect(_on_listener_canceled)
	_update_consumer_names()
	if is_instance_valid(interactable):
		interactable.bus_path = bus_path
	if is_instance_valid(listener):
		listener.bus_path = bus_path


func _update_consumer_names() -> void:
	var base_name := target_label if target_label != "" else target_key
	if base_name == "":
		base_name = name
	if is_instance_valid(interactable):
		interactable.name = "%sInteractable" % base_name
	if is_instance_valid(listener):
		listener.name = "%sListener" % base_name


func _apply_filters_to_consumers() -> void:
	var target_path := get_target_path()
	for consumer in [interactable, listener]:
		if not is_instance_valid(consumer):
			continue
		consumer.surface_id_filter = surface_id_filter
		consumer.target_path_filter = target_path
		consumer.pointer_id_filter = pointer_id_filter


func _connect_consumer_to_bus(bus: AeroUiInteractionBus, consumer: Node) -> void:
	if not is_instance_valid(bus) or not is_instance_valid(consumer):
		return
	var handler := Callable(consumer, "_on_bus_interaction_event")
	if not bus.interaction_event.is_connected(handler):
		bus.interaction_event.connect(handler)


func _disconnect_consumer_from_bus(bus: AeroUiInteractionBus, consumer: Node) -> void:
	if not is_instance_valid(bus) or not is_instance_valid(consumer):
		return
	var handler := Callable(consumer, "_on_bus_interaction_event")
	if bus.interaction_event.is_connected(handler):
		bus.interaction_event.disconnect(handler)


func _on_interactable_interaction_event(event: AeroUiInteractionEvent) -> void:
	last_event = event
	interaction_event.emit(self, event)
	_emit_state_changed()


func _on_interactable_hovered_changed(next_is_hovered: bool, event: AeroUiInteractionEvent) -> void:
	is_hovered = next_is_hovered
	last_event = event
	hovered_changed.emit(self, is_hovered, event)
	_emit_state_changed()


func _on_interactable_pressed_changed(next_is_pressed: bool, event: AeroUiInteractionEvent) -> void:
	is_pressed = next_is_pressed
	last_event = event
	pressed_changed.emit(self, is_pressed, event)
	_emit_state_changed()


func _on_interactable_dragging_changed(next_is_dragging: bool, event: AeroUiInteractionEvent) -> void:
	is_dragging = next_is_dragging
	last_event = event
	dragging_changed.emit(self, is_dragging, event)
	_emit_state_changed()


func _on_interactable_canceled(event: AeroUiInteractionEvent) -> void:
	last_event = event
	is_hovered = false
	is_pressed = false
	is_dragging = false
	canceled.emit(self, event)
	_emit_state_changed()


func _on_listener_interaction_event(event: AeroUiInteractionEvent) -> void:
	last_event = event
	match event.phase:
		AeroUiInteractionTypes.PHASE_PRESS_BEGIN:
			press_count += 1
		AeroUiInteractionTypes.PHASE_PRESS_END:
			release_count += 1
		AeroUiInteractionTypes.PHASE_DRAG_BEGIN, AeroUiInteractionTypes.PHASE_DRAG_MOVE:
			drag_count += 1
		_:
			pass
	_emit_state_changed()


func _on_listener_tapped(event: AeroUiInteractionEvent) -> void:
	last_event = event
	tap_count += 1
	tapped.emit(self, event)
	_emit_state_changed()


func _on_listener_canceled(event: AeroUiInteractionEvent) -> void:
	last_event = event
	_emit_state_changed()


func _emit_state_changed() -> void:
	state_changed.emit(self)
