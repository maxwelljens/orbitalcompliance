# globals.gd
class_name Globals
extends Node

signal action_denied
signal new_order_arrived(new_component: Component)
signal component_selected(selected_component: Component)
signal component_loaded(loaded_component: Component)
signal component_rejected
signal lost

enum Country { UNKNOWN, TEXAS, CALIFORNIA, NEW_YORK, CANADA, CHINA, INDIA,
GERMANY, FRANCE, UNITED_KINGDOM, POLAND, ETU }
enum TCPUArch { UNKNOWN, RISC_V, X86_64, ARMV9_0 }
enum Lubricant { UNKNOWN, SL_7, SL_9, PETROCHEM_STD, CRYO_50 }
enum Socket { THREE_POINT, FOUR_POINT, OW_SPLINE }
enum PowerConnector { EB_STD, NW_HIGHVOLT, OW_PHASE }
enum Steel { UNKNOWN, PN_H_85020, ASTM_A516_G70, ASTM_A36, GOST_1050_88,
GOST_15X }
enum ComponentType { TCPU, DRILLHEAD, GEARBOX }

var orders: Array[Component]
var rig_slots: Dictionary[int, Component]
var selected_order: Component
var selected_rig_slot: Component
