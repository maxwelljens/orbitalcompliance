class_name RigSlotTemplate
extends ComponentTemplate

var rig_slot: int

func refresh_display() -> void:
	var name_txt_format = "[b]{0}[/b] - [color=gray]{1}[/color]"
	if component is TCPU:
		var desc_txt_format = "[table=4][cell][b]Arch[/b][/cell] [cell]{0}[/cell] [cell][b]TFLOPS[/b][/cell] [cell]{1}[/cell] [cell][b]W[/b][/cell] [cell]{2}[/cell][/table]"
		%Name.text = name_txt_format.format([component.name, str(component.id).pad_zeros(3)])
		%Description.text = desc_txt_format.format([globals.TCPUArch.keys()[component.architecture].rpad(12), component.teraflops, component.max_wattage])
