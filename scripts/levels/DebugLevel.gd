extends Node3D


var elvup = false

func _on_button_interacted():
	if elvup:
		$CSGBox3D16/AnimationPlayer.play_backwards("Go Up")
		elvup = false
	else:
		$CSGBox3D16/AnimationPlayer.play("Go Up")
		elvup = true
