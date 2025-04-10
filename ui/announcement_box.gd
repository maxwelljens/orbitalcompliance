class_name AnnouncementBox
extends PanelContainer

const ERROR_BB := "[color=#c94f6d][b]ERROR:[/b][/color] "

func display_message(message: String, error := false) -> void:
	if error:
		%Message.text = ERROR_BB + message
	else:
		%Message.text += message
	%AnimationPlayer.play("show")
