extends HeldGun


var ShootDown = false


func _physics_process(delta):
	if ShootDown:
		Shoot()

func Use():
	ShootDown = true
func UnUse():
	ShootDown = false
