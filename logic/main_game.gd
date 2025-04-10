extends Control

signal action_denied
signal module_loaded

@export var globals: Globals
@export_category("Orders UI")
@export var comp_list_display: VBoxContainer
@export var comp_template: ComponentTemplate
@export_category("Rig Slots UI")
@export var rig_slots_list_display: VBoxContainer
@export var rig_slots_template: RigSlotTemplate
@export_category("UI General")
@export var announcement_box: AnnouncementBox

enum RSlot { TCPU, DRILLHEAD_A, DRILLHEAD_B, GEARBOX_A, GEARBOX_B }

const TCPU_ARCHITECTURE = globals.TCPUArch.RISC_V
const MAX_WATTAGE = 9000
const MAX_DRILL_DIAMETER = 250
const MIN_FLOPS = 375
const MIN_DRILL_TORQUE = 850
const MIN_GEARBOX_TORQUE = 850
const STEEL_TYPES = [globals.Steel.PN_H_85020, globals.Steel.ASTM_A516_G70]
const LUBRICANT_TYPES = [globals.Lubricant.SL_7, globals.Lubricant.PETROCHEM_STD]
const SOCKET_TYPES = [globals.Socket.THREE_POINT, globals.Socket.FOUR_POINT]

var orders: Array[Component]
var selected_order: Component
var rig_slots: Dictionary[int, Component]
var selected_rig_slot: Component

func _ready():
	announcement_box.display_message("Poopoo", true)
	RenderingServer.set_default_clear_color("#192330")
	_initialise_rig()
	_initialise_orders()
	_populate_displays()

func _initialise_rig():
	rig_slots = {
		RSlot.TCPU: TCPU.new(),
		RSlot.DRILLHEAD_A: DrillHead.new(),
		RSlot.DRILLHEAD_B: DrillHead.new(),
		RSlot.GEARBOX_A: Gearbox.new(),
		RSlot.GEARBOX_B: Gearbox.new()
	}

	rig_slots[RSlot.TCPU].id = RSlot.TCPU
	rig_slots[RSlot.TCPU].name = "Poop CPU"
	rig_slots[RSlot.TCPU].origin = globals.Country.POLAND
	rig_slots[RSlot.TCPU].manifest = 0
	rig_slots[RSlot.TCPU].architecture = globals.TCPUArch.RISC_V
	rig_slots[RSlot.TCPU].teraflops = 400
	rig_slots[RSlot.TCPU].max_wattage = 9000

	# Just unique IDs for now
	rig_slots[RSlot.DRILLHEAD_A].id = RSlot.DRILLHEAD_A
	rig_slots[RSlot.DRILLHEAD_B].id = RSlot.DRILLHEAD_B
	rig_slots[RSlot.GEARBOX_A].id = RSlot.GEARBOX_A
	rig_slots[RSlot.GEARBOX_B].id = RSlot.GEARBOX_B

func _initialise_orders() -> void:
	for i in range(3):
		var new_order := TCPU.new()	
		new_order.id = 100 + i
		new_order.name = ["Haswell", "Ultra", "XLR"].pick_random()
		new_order.origin = randi() % len(globals.Country)
		new_order.manifest = 0
		new_order.architecture = randi() % len(globals.TCPUArch)
		new_order.teraflops = 350 + (randi() % 4) * 15
		new_order.max_wattage = 8500 + (randi() % 10) * 100
		orders.append(new_order)

func _populate_displays() -> void:
	# Orders
	for comp in orders:
		var new_node: ComponentTemplate = comp_template.duplicate()
		comp_list_display.add_child(new_node)
		new_node.init_component_display(comp)
	# Rig slots
	for slot in rig_slots:
		var new_node: RigSlotTemplate = rig_slots_template.duplicate()
		rig_slots_list_display.add_child(new_node)
		new_node.rig_slot = slot
		new_node.init_component_display(rig_slots[slot])

func _update_order_list() -> void:
	for node in comp_list_display.get_children():
		if node.component not in orders:
			node.queue_free()

func _update_rig_slot_list() -> void:
	for node: RigSlotTemplate in rig_slots_list_display.get_children():
		if node.rig_slot == RSlot.TCPU:
			node.component = selected_order
			node.refresh_display()
			node.deselect()

func _install_component_logic() -> void:
	pass

func _on_component_template_component_selected(component: Component) -> void:
	for entry in comp_list_display.get_children():
		entry.deselect()
	selected_order = component

func _on_rig_slot_template_component_selected(component: Component) -> void:
	for entry in rig_slots_list_display.get_children():
		entry.deselect()
	selected_rig_slot = component

func _on_accept_button_pressed() -> void:
	if selected_order == null or selected_rig_slot == null:
		action_denied.emit()
		print("ERROR: Selections missing")
		return
	if selected_rig_slot != rig_slots[RSlot.TCPU]:
		action_denied.emit()
		print("ERROR: Not the right slot picked")
		return
	module_loaded.emit()
	rig_slots[RSlot.TCPU] = selected_order
	orders.erase(selected_order)
	_install_component_logic()
	_update_rig_slot_list()
	_update_order_list()
	selected_order = null
	selected_rig_slot = null
