extends HeldItem
class_name HeldGun

var Shooting = false
var Aiming = false

@onready var RNG = RandomNumberGenerator.new()
@onready var BulletHole = preload("res://scenes/objects/BulletHole.tscn")

func _ready():
	User.sprint.connect(UserSprint)
	User.unsprint.connect(UserUnSprint)
	if item is Gun:
		$Shoot.stream = item.shoot_sound
		$NoBullet.stream = item.no_bullet_sound
func Use():
	if not Shooting:
		Shoot()
func  SecondaryUse():
	Aim()
func SecondaryUnUse():
	UnAim()
func Shoot():
	if not Shooting and item.ammo > 0:
		item.ammo -= 1
		Shooting = true
		$Shoot.play()
		$AnimationPlayer.stop()
		if Aiming:
			$AnimationPlayer.play("AimShoot")
		else:
			$AnimationPlayer.play("Shoot")

		for i in range(item.bullet_ammount):
			var rand = (abs(1-item.accuracy))*25
			var spreadDir = Vector2(RNG.randf_range(-1,1),RNG.randf_range(-1,1)).normalized()
			var spread = spreadDir * randf_range(0,rand)
			if Aiming:
				spread*=0.8
			var Cast:RayCast3D = RayCast3D.new()
			$Bullets.add_child(Cast)
			Cast.position = Vector3()
			Cast.enabled = true
			Cast.target_position = Vector3(0,0,-1000)
			Cast.collision_mask = 5
			Cast.rotation_degrees = Vector3(spread.x,spread.y,0)
			Cast.force_raycast_update()
		for Cast in $Bullets.get_children():
			if Cast.is_colliding():
				
			
				if Cast.get_collider().is_in_group("Enemy"):
					Cast.get_collider().Hit(false,self,Global.GunDamage)
				
				var hole = BulletHole.instantiate()
					
				Cast.get_collider().add_child(hole)
				hole.global_position = Cast.get_collision_point() + (Cast.get_collision_normal()/80)
				if abs(Cast.get_collision_normal().y) == 1:
					hole.rotation_degrees.x = 90
				else:
					hole.look_at(Cast.get_collision_point()-Cast.get_collision_normal(),Vector3.UP)
			Cast.queue_free()
			
		if Aiming:
			Recoil(item.recoil*0.8)
		else:
			Recoil(item.recoil)

		await get_tree().create_timer(item.shoot_cooldown).timeout
		Shooting = false
	elif not Shooting:
		$NoBullet.play()
func Recoil(force):
	var yf =  RNG.randf_range(-force,force)
	var xf =  RNG.randf_range(-force,force)
	User.CameraOffset = Vector2(xf,yf)*0.5
	User.MoveCamera(Vector2(xf,yf))
func Aim():
	if not Aiming and not User.Sliding:
		User.UnSprint()
		Aiming = true
		$AnimationPlayer.play("Aim")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("AimIdle")
		User.SetFov(-item.aim_zoom)
		User.SetMovementSpeed(0.5)
func UnAim():
	if Aiming:
		Aiming = false
		$AnimationPlayer.play_backwards("Aim")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("Idle")
		User.SetFov(0.0)
		User.SetMovementSpeed(1)
func UserSprint():
	UnAim()
func UserUnSprint():
	if Aiming:
		User.SetFov(-item.aim_zoom)
