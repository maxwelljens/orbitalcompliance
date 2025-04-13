class_name ComponentList
extends VBoxContainer

@export var comp_template: PackedScene
@export_enum("Orders", "Rig Slots") var comp_list_type := 0

@onready var globals: Globals = GlobalsNode

@onready var comp_template_instance: ComponentTemplate = comp_template.instantiate()

func _ready() -> void:
	globals.new_order_arrived.connect(_on_new_order_arrived)
	globals.component_loaded.connect(_on_component_loaded)
	globals.component_rejected.connect(_on_component_rejected)
	globals.component_selected.connect(_on_component_selected)

func _refresh_display() -> void:
	for node in get_children():
		node.queue_free()
	match comp_list_type:
		0:
			for order in globals.orders:
				var new_node: ComponentTemplate = comp_template_instance.duplicate()
				new_node.init_component_display(order)
				add_child(new_node)
		1:
			for slot in globals.rig_slots:
				var new_node: ComponentTemplate = comp_template_instance.duplicate()
				new_node.init_component_display(globals.rig_slots[slot])
				add_child(new_node)

func _on_component_selected(selected_component: Component) -> void:
	var node_in_list := false
	for node in get_children():
		if node.component == selected_component:
			node_in_list = true
	if not node_in_list:
		return
	for node in get_children():
		if node.component != selected_component:
			node.deselect()

func _on_new_order_arrived(_new_component: Component) -> void:
	_refresh_display()

func _on_component_loaded(_loaded_component: Component) -> void:
	_refresh_display()

func _on_component_rejected() -> void:
	_refresh_display()
