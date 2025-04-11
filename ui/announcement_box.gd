class_name AnnouncementBox
extends PanelContainer

@export var animation_player: AnimationPlayer
@export_range(1.0, 4.0, 0.5) var time_displayed: float = 2.0

const ERROR_BB := "[color=#c94f6d][b]ERROR:[/b][/color] "

var message_received: bool
var displaying: bool
var timer: float

func _process(delta: float) -> void:
	if not displaying:
		return
	if message_received:
		timer = 0.0
		message_received = false
	timer += delta
	if timer >= time_displayed:
		displaying = false
		animation_player.play("hide_announcement")

func display_message(message: String, error := true) -> void:
	if error:
		%Message.text = ERROR_BB + message
	else:
		%Message.text += message
	message_received = true
	if not displaying:
		animation_player.play("show_announcement")
		displaying = true

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "show_announcement":
		self.visible = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide_announcement":
		self.visible = false
