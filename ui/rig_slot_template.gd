class_name RigSlotTemplate
extends PanelContainer

@export var globals: Globals

var component: Component
var selected: bool

func init_component_display(new_component: Component) -> void:
	component = new_component
	if component is TCPU:
		%Name.text = component.architecture

func _on_panel_button_pressed() -> void:
	if selected:
		selected = false
	else:
		selected = true
	%Selected.button_pressed = selected
