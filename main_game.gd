extends Control

@export var globals: Globals

enum SystemStatus { NOMINAL, WARNING, ERROR, OFFLINE }

const TCPU_ARCHITECTURE = globals.TCPUArch.RISC_V
const MIN_FLOPS = 375.0
const MAX_WATTAGE = 9000
const MAX_DRILL_DIAMETER = 250
const MIN_DRILL_TORQUE = 850
const MIN_GEARBOX_TORQUE = 850
const STEEL_TYPES = [globals.Steel.PN_H_85020, globals.Steel.ASTM_A516_G70]
const LUBRICANT_TYPES = [globals.Lubricant.SL_7, globals.Lubricant.PETROCHEM_STD]
const SOCKET_TYPES = [globals.Socket.THREE_POINT, globals.Socket.FOUR_POINT]

var current_cycle: int = 0
var incoming_shipments: Array[Component]
var rig_systems: Dictionary[String, Component]
var game_log: Array[String]

func _ready():
	_initialize_rig()

func _initialize_rig():
	rig_systems = {
		"TCPU": TCPU.new(),
		"Drill A": DrillHead.new(),
		"Drill B": DrillHead.new(),
		"Gearbox A": Gearbox.new(),
		"Gearbox B": Gearbox.new()
	}
	rig_systems["TCPU"].id = 0
	rig_systems["TCPU"].name = "Lmao CPU"
	rig_systems["TCPU"].origin = globals.Country.CHINA
	rig_systems["TCPU"].manifest = 0
	rig_systems["TCPU"].architecture = globals.TCPUArch.RISC_V
	rig_systems["TCPU"].teraflops = 400
	rig_systems["TCPU"].max_wattage = 9000
	game_log.clear()
	incoming_shipments.clear()
	current_cycle = 0
	var new_node: ComponentTemplate = %ComponentTemplate.duplicate()
	%ComponentList.add_child(new_node)
	new_node.init_component_display(rig_systems["TCPU"])
