extends Area2D

func _on_area_entered(area):
	if area.is_in_group("Player"):
		area.get_parent().set_visibility(true)

func _on_area_exited(area):
	if area.is_in_group("Player"):
		area.get_parent().set_visibility(false)
