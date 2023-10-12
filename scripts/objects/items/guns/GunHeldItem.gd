extends HeldItem
class_name HeldGun

var Shooting = false
var Aiming = false
var CanShoot = true

@onready var RNG = RandomNumberGenerator.new()
@onready var BulletHole = preload("res://scenes/objects/BulletHole.tscn")

func _ready():
	super._ready()
	User.sprint.connect(UserSprint)
	User.unsprint.connect(UserUnSprint)
	User.crouch.connect(UserCrouch)
	User.uncrouch.connect(UserUnCrouch)
	if item is Gun:
		$Shoot.stream = item.shoot_sound
		$NoBullet.stream = item.no_bullet_sound
	$AnimationPlayer.play("Idle")
func Use():
	if not Shooting:
		Shoot()
func UnHold():
	User.SetFov(0.0)
	User.SetMovementSpeed(1)
	User.SetSensitivityScale(1)
	super.UnHold()
	
func  SecondaryUse():
	Aim()
func SecondaryUnUse():
	UnAim()
func Shoot():
	if not Shooting and item.ammo > 0 and CanShoot:
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
			Cast.collision_mask = 35
			Cast.rotation_degrees = Vector3(spread.x,spread.y,0)
			Cast.force_raycast_update()
		for Cast in $Bullets.get_children():
			if Cast.is_colliding():
				
				var Hit = Cast.get_collider()
				if Hit.is_in_group("Enemy"):
					Hit.Hit(item.damage)
				if Hit.is_in_group("Props"):
					if Hit is RigidBody3D:
						print("proip")
						var dir = Vector3()
						dir = Vector3.FORWARD.rotated(Vector3(1,0,0),global_rotation.y)
						dir = dir.rotated(Vector3(0,1,0),global_rotation.x)
						print(global_rotation)
						Hit.apply_impulse(dir * item.damage/10,Cast.get_collision_point())
				var hole = BulletHole.instantiate()
					
				Hit.add_child(hole)
				hole.global_position = Cast.get_collision_point() + (Cast.get_collision_normal()/80)
				hole.global_rotation = Vector3()
				var normal : Vector3 = Cast.get_collision_normal()
				var bulrot = Vector3()
				bulrot.x += Vector2(abs(normal.x)+abs(normal.z)/2,-normal.y).angle()
				bulrot.y += Vector2(normal.x,-normal.z).angle() + deg_to_rad(90)
				bulrot.z += deg_to_rad(RNG.randf_range(0.0,360.0))
				hole.global_rotation = bulrot
			Cast.queue_free()
			
		if Aiming:
			Recoil(item.recoil*0.8)
		else:
			Recoil(item.recoil)

		await get_tree().create_timer(item.shoot_cooldown).timeout
		Shooting = false
	elif not Shooting and CanShoot:
		$NoBullet.play()
func Recoil(force):
	var yf =  RNG.randf_range(-force,force)
	var xf =  RNG.randf_range(-force,force)
	User.CameraOffset = Vector2(xf,yf)*0.5
	User.MoveCamera(Vector2(xf/(User.Sensitivity * User.SensitivityScale),yf/(User.Sensitivity * User.SensitivityScale)))
func Aim():
	if not Aiming:
		User.UnSprint()
		Aiming = true
		$AnimationPlayer.play("Aim")
		CanShoot = false
		await $AnimationPlayer.animation_finished
		CanShoot = true
		$AnimationPlayer.play("AimIdle")
		User.SetFov(-item.aim_zoom * 74)
		User.SetSensitivityScale(1.0 - item.aim_zoom + 0.01)
		if User.Crouching:
			User.SetMovementSpeed(0.5* User.CrouchSpeed)
		elif User.Sliding:
			pass
		else:
			User.SetMovementSpeed(0.5)
func UnAim():
	if Aiming:
		Aiming = false
		$AnimationPlayer.play_backwards("Aim")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("Idle")
		User.SetFov(0.0)
		User.SetSensitivityScale(1.0)
		if User.Crouching:
			User.SetMovementSpeed(User.CrouchSpeed)
		elif User.Sliding:
			pass
		elif User.Sprinting:
			pass
		else:
			User.SetMovementSpeed(1)
func UserSprint():
	UnAim()
func UserUnSprint():
	if Aiming:
		User.SetFov(-item.aim_zoom)
func UserCrouch():
	if Aiming:
		User.SetFov(-item.aim_zoom)
		User.SetMovementSpeed(0.5 * User.CrouchSpeed)
func UserUnCrouch():
	if Aiming:
		User.SetFov(-item.aim_zoom)
		User.SetMovementSpeed(0.5)
