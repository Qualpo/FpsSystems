extends Node3D


var elvup = false

func _on_button_interacted():
	if elvup:
		$Level/CSGBox3D16/AnimationPlayer.play_backwards("Go Up")
		elvup = false
	else:
		$Level/CSGBox3D16/AnimationPlayer.play("Go Up")
		elvup = true
