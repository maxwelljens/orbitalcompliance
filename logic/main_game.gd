extends Control

@export_category("Logic")
@export var rig: Rig
@export var sfx: SFX
@export_category("UI")
@export var announcement_box: AnnouncementBox

@onready var globals: Globals = GlobalsNode

var order_id := 0

func _ready():
	RenderingServer.set_default_clear_color("#192330")
	globals.component_selected.connect(_on_component_selected)
	for i in range(3):
		_generate_order(globals.ComponentType.TCPU)

func _on_component_selected(selected_component: Component):
	for order in globals.orders:
		if selected_component == order:
			globals.selected_order = selected_component
			return
	for slot in rig.globals.rig_slots:
		if selected_component == rig.globals.rig_slots[slot]:
			globals.selected_rig_slot = selected_component
			return

func _generate_order_id() -> int:
	order_id += 1
	return order_id

func _generate_order(type: int) -> void:
	var new_order: Component
	match type:
		globals.ComponentType.TCPU: new_order = TCPU.new()
		globals.ComponentType.DRILLHEAD: new_order = DrillHead.new()
		globals.ComponentType.GEARBOX: new_order = Gearbox.new()
	new_order.id = _generate_order_id()
	new_order.name = ["Haswell", "Ultra", "XLR"].pick_random()
	new_order.origin = randi() % len(globals.Country)
	new_order.manifest = 0
	new_order.architecture = globals.TCPUArch.RISC_V
	new_order.teraflops = 350 + (randi() % 4) * 15
	new_order.max_wattage = 8500 + (randi() % 10) * 100
	globals.orders.append(new_order)
	globals.new_order_arrived.emit(new_order)

func _validate_component_installation() -> void:
	var arch_mismatch: bool
	var teraflops_too_low: bool
	var wattage_too_high: bool
	if globals.selected_order.architecture != rig.TCPU_ARCHITECTURE:
		arch_mismatch = true
		%GameOverText.text += "Architecture mismatch (RISC-V needed)\n"
	if globals.selected_order.teraflops < rig.MIN_TERAFLOPS:
		teraflops_too_low = true
		%GameOverText.text += "Too few teraFLOPS (375 is minimum)\n"
	if globals.selected_order.max_wattage > rig.MAX_WATTAGE:
		wattage_too_high = true
		%GameOverText.text += "Wattage too high (9000 is max)\n"
	if arch_mismatch or teraflops_too_low or wattage_too_high:
		%GameOverScreen.visible = true
		globals.lost.emit()

func _on_accept_button_pressed() -> void:
	if globals.selected_order == null or globals.selected_rig_slot == null:
		globals.action_denied.emit()
		announcement_box.display_message("Selections missing")
		return
	if globals.selected_rig_slot != rig.globals.rig_slots[rig.RSlot.TCPU]:
		globals.action_denied.emit()
		announcement_box.display_message("Wrong slot picked")
		return
	rig.globals.rig_slots[rig.RSlot.TCPU] = globals.selected_order
	globals.orders.erase(globals.selected_order)
	_validate_component_installation()
	globals.component_loaded.emit(globals.selected_order)
	globals.selected_order = null
	globals.selected_rig_slot = null

func _validate_component_rejection() -> void:
	var arch_mismatch: bool
	var teraflops_too_low: bool
	var wattage_too_high: bool
	if globals.selected_order == null:
		globals.action_denied.emit()
		announcement_box.display_message("No order selected")
		return
	if globals.selected_order.architecture != rig.TCPU_ARCHITECTURE:
		arch_mismatch = true
	if globals.selected_order.teraflops < rig.MIN_TERAFLOPS:
		teraflops_too_low = true
	if globals.selected_order.max_wattage > rig.MAX_WATTAGE:
		wattage_too_high = true
	if !arch_mismatch and !teraflops_too_low and !wattage_too_high:
		%GameOverText.text += "This component was suitable for the rig"
		%GameOverScreen.visible = true
		globals.lost.emit()

func _on_reject_button_pressed() -> void:
	_validate_component_rejection()
	globals.orders.erase(globals.selected_order)
	globals.component_rejected.emit()
	globals.selected_order = null

func _on_add_pressed() -> void:
	_generate_order(globals.ComponentType.TCPU)
