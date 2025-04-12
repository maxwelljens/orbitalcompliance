extends Control

signal action_denied
signal new_order_arrived(new_component: Component)
signal component_loaded
signal component_rejected
signal lost

@export_category("Orders UI")
@export var comp_list_display: VBoxContainer
@export var comp_template: ComponentTemplate
@export_category("Rig Slots UI")
@export var rig_slots_list_display: VBoxContainer
@export var rig_slots_template: RigSlotTemplate
@export_category("UI General")
@export var announcement_box: AnnouncementBox

@onready var globals: Globals = GlobalsNode

enum RSlot { TCPU, DRILLHEAD_A, DRILLHEAD_B, GEARBOX_A, GEARBOX_B }

const TCPU_ARCHITECTURE = globals.TCPUArch.RISC_V
const MAX_WATTAGE = 9000
const MAX_DRILL_DIAMETER = 250
const MIN_TERAFLOPS = 375
const MIN_DRILL_TORQUE = 850
const MIN_GEARBOX_TORQUE = 850
const STEEL_TYPES = [globals.Steel.PN_H_85020, globals.Steel.ASTM_A516_G70]
const LUBRICANT_TYPES = [globals.Lubricant.SL_7, globals.Lubricant.PETROCHEM_STD]
const SOCKET_TYPES = [globals.Socket.THREE_POINT, globals.Socket.FOUR_POINT]

var orders: Array[Component]
var rig_slots: Dictionary[int, Component]

func _ready():
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
		new_order.architecture = globals.TCPUArch.RISC_V
		new_order.teraflops = 350 + (randi() % 4) * 15
		new_order.max_wattage = 8500 + (randi() % 10) * 100
		orders.append(new_order)
		new_order_arrived.emit(new_order)

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
	# Delete UI nodes for orders no longer in list
	for node in comp_list_display.get_children():
		if node.component not in orders:
			node.queue_free()

func _update_rig_slot_list() -> void:
	for node: RigSlotTemplate in rig_slots_list_display.get_children():
		if node.rig_slot == RSlot.TCPU:
			node.component = globals.selected_order
			node.refresh_display()
			node.deselect()

func _validate_component_installation() -> void:
	var arch_mismatch: bool
	var teraflops_too_low: bool
	var wattage_too_high: bool
	if globals.selected_order.architecture != TCPU_ARCHITECTURE:
		arch_mismatch = true
		%GameOverText.text += "Architecture mismatch (RISC-V needed)\n"
	if globals.selected_order.teraflops < MIN_TERAFLOPS:
		teraflops_too_low = true
		%GameOverText.text += "Too few teraFLOPS (375 is minimum)\n"
	if globals.selected_order.max_wattage > MAX_WATTAGE:
		wattage_too_high = true
		%GameOverText.text += "Wattage too high (9000 is max)\n"
	if arch_mismatch or teraflops_too_low or wattage_too_high:
		%GameOverScreen.visible = true
		lost.emit()

func _on_component_template_component_selected() -> void:
	for entry in comp_list_display.get_children():
		entry.deselect()

func _on_rig_slot_template_component_selected() -> void:
	for entry in rig_slots_list_display.get_children():
		entry.deselect()

func _on_accept_button_pressed() -> void:
	if globals.selected_order == null or globals.selected_rig_slot == null:
		action_denied.emit()
		announcement_box.display_message("Selections missing")
		return
	if globals.selected_rig_slot != rig_slots[RSlot.TCPU]:
		action_denied.emit()
		announcement_box.display_message("Wrong slot picked")
		return
	component_loaded.emit()
	rig_slots[RSlot.TCPU] = globals.selected_order
	orders.erase(globals.selected_order)
	_validate_component_installation()
	_update_rig_slot_list()
	_update_order_list()
	globals.selected_order = null
	globals.selected_rig_slot = null

func _validate_component_rejection() -> void:
	var arch_mismatch: bool
	var teraflops_too_low: bool
	var wattage_too_high: bool
	if globals.selected_order == null:
		action_denied.emit()
		announcement_box.display_message("No order selected")
		return
	if globals.selected_order.architecture != TCPU_ARCHITECTURE:
		arch_mismatch = true
	if globals.selected_order.teraflops < MIN_TERAFLOPS:
		teraflops_too_low = true
	if globals.selected_order.max_wattage > MAX_WATTAGE:
		wattage_too_high = true
	if !arch_mismatch and !teraflops_too_low and !wattage_too_high:
		%GameOverText.text += "This component was suitable for the rig"
		%GameOverScreen.visible = true
		lost.emit()

func _on_reject_button_pressed() -> void:
	_validate_component_rejection()
	component_rejected.emit()
	orders.erase(globals.selected_order)
	_update_order_list()
	globals.selected_order = null
