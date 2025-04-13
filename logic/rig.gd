class_name Rig
extends Node

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

func _ready() -> void:
	globals.rig_slots = {
		RSlot.TCPU: TCPU.new(),
		RSlot.DRILLHEAD_A: DrillHead.new(),
		RSlot.DRILLHEAD_B: DrillHead.new(),
		RSlot.GEARBOX_A: Gearbox.new(),
		RSlot.GEARBOX_B: Gearbox.new()
	}

	globals.rig_slots[RSlot.TCPU].id = RSlot.TCPU
	globals.rig_slots[RSlot.TCPU].name = "Poop CPU"
	globals.rig_slots[RSlot.TCPU].origin = globals.Country.POLAND
	globals.rig_slots[RSlot.TCPU].manifest = 0
	globals.rig_slots[RSlot.TCPU].architecture = globals.TCPUArch.RISC_V
	globals.rig_slots[RSlot.TCPU].teraflops = 400
	globals.rig_slots[RSlot.TCPU].max_wattage = 9000

	# Just unique IDs for now
	globals.rig_slots[RSlot.DRILLHEAD_A].id = RSlot.DRILLHEAD_A
	globals.rig_slots[RSlot.DRILLHEAD_B].id = RSlot.DRILLHEAD_B
	globals.rig_slots[RSlot.GEARBOX_A].id = RSlot.GEARBOX_A
	globals.rig_slots[RSlot.GEARBOX_B].id = RSlot.GEARBOX_B
