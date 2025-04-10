class_name SFX
extends Node

@onready var music: Dictionary[String, AudioStreamPlayer] = {
	&"Factory": AudioStreamPlayer.new()
}

@onready var ui_sound: Dictionary[String, AudioStreamPlayer] = {
	&"Click": AudioStreamPlayer.new(),
	&"DenyClick": AudioStreamPlayer.new(),
	&"LoadModule": AudioStreamPlayer.new()
}

func _ready() -> void:
	for s in ui_sound:
		# play() does not work if node not instantiated in scene
		self.add_child(ui_sound[s])
		ui_sound[s].bus = &"UI"
	for s in music:
		self.add_child(music[s])
		music[s].bus = &"Music"
	music["Factory"].stream = load("res://sound/music/factory.ogg")
	ui_sound["Click"].stream = load("res://sound/ui/select_click.ogg")
	ui_sound["DenyClick"].stream = load("res://sound/ui/deny_click.ogg")
	ui_sound["LoadModule"].stream = load("res://sound/ui/load_module.ogg")

func _on_main_game_action_denied() -> void:
	ui_sound["DenyClick"].play()

func _on_main_game_module_loaded() -> void:
	ui_sound["LoadModule"].play()

func _on_component_template_component_selected(_component: Component) -> void:
	ui_sound["Click"].play()

func _on_rig_slot_template_component_selected(_component: Component) -> void:
	ui_sound["Click"].play()
