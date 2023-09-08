extends Area3D


signal  Interacted

func Interact(interacter):
	$AudioStreamPlayer3D.play()
	emit_signal("Interacted")
