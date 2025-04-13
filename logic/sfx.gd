class_name SFX
extends Node

@onready var globals: Globals = GlobalsNode

@onready var music: Dictionary[String, AudioStreamPlayer] = {
	&"Factory": AudioStreamPlayer.new(),
	&"Forest": AudioStreamPlayer.new()
}

@onready var ui_sound: Dictionary[String, AudioStreamPlayer] = {
	&"Click": AudioStreamPlayer.new(),
	&"DenyClick": AudioStreamPlayer.new(),
	&"LoadModule": AudioStreamPlayer.new(),
	&"RejectModule": AudioStreamPlayer.new(),
	&"Alarm": AudioStreamPlayer.new()
}

func _ready() -> void:
	# --- SIGNALS ---
	globals.component_loaded.connect(_on_component_loaded)
	globals.component_rejected.connect(_on_component_rejected)
	globals.component_selected.connect(_on_component_selected)
	globals.action_denied.connect(_on_action_denied)
	globals.lost.connect(_on_game_lost)

	# --- SOUNDS ---
	# Instantiate nodes
	for s in ui_sound:
		self.add_child(ui_sound[s])
		ui_sound[s].bus = &"UI"
	for s in music:
		self.add_child(music[s])
		music[s].bus = &"Music"

	# Set resources
	music["Factory"].stream = load("res://sound/music/factory.ogg")
	music["Forest"].stream = load("res://sound/music/forest.ogg")
	ui_sound["Click"].stream = load("res://sound/ui/select_click.ogg")
	ui_sound["DenyClick"].stream = load("res://sound/ui/deny_click.ogg")
	ui_sound["DenyClick"].volume_linear = 0.5
	ui_sound["LoadModule"].stream = load("res://sound/ui/load_module.ogg")
	ui_sound["RejectModule"].stream = load("res://sound/ui/reject_module.ogg")
	ui_sound["Alarm"].stream = load("res://sound/ui/alarm.ogg")

	# START MUSIC
	music["Factory"].play()

func _on_action_denied() -> void:
	ui_sound["DenyClick"].play()

func _on_component_loaded(_loaded_component: Component) -> void:
	ui_sound["LoadModule"].play()

func _on_component_rejected() -> void:
	ui_sound["RejectModule"].play()

func _on_component_selected(_selected_component: Component) -> void:
	ui_sound["Click"].play()

func _on_component_template_component_selected() -> void:
	ui_sound["Click"].play()

func _on_rig_slot_template_component_selected() -> void:
	ui_sound["Click"].play()

func _on_tab_container_tab_clicked(_tab: int) -> void:
	ui_sound["Click"].play()

func _on_game_lost() -> void:
	music["Factory"].stop()
	music["Forest"].play()

