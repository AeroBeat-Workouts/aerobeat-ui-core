@tool
class_name AeroButtonBase
extends Button

signal invoked

func _pressed() -> void:
	invoked.emit()
