extends HeldItem
class_name HeldGun

var Shooting = false
var RNG = RandomNumberGenerator.new()

func _ready():
	if item is Gun:
		$Shoot.stream = item.shoot_sound
		$NoBullet.stream = item.no_bullet_sound

func Use():
	if not Shooting:
		Shoot()
func Shoot():
	if not Shooting and item.ammo > 0:
		item.ammo -= 1
		Shooting = true
		$Shoot.play()
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Shoot")

		for i in range(item.bullet_ammount):
			var rand = (abs(1-item.accuracy))*25
			var spreadDir = Vector2(RNG.randf_range(-1,1),RNG.randf_range(-1,1)).normalized()
			var spread = spreadDir * randf_range(0,rand)
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
				
			#	var hole = BulletHole.instantiate()
					
			#	Cast.get_collider().add_child(hole)
		#		hole.global_position = Cast.get_collision_point() + (Cast.get_collision_normal()/80)
		#		if abs(Cast.get_collision_normal().y) == 1:
			#		hole.rotation_degrees.x = 90
			#	else:
			#		hole.look_at(Cast.get_collision_point()-Cast.get_collision_normal(),Vector3.UP)
			Cast.queue_free()
		Recoil(item.recoil)
#		user.CameraOffset.x += recoil * 3
#		user.CameraDirection.x += recoil
#		user.CameraDirection.x = clamp(user.CameraDirection.x,-90,90)

		await get_tree().create_timer(item.shoot_cooldown).timeout
		Shooting = false
	elif not Shooting:
		$NoBullet.play()
func Recoil(force):
	var yf =  RNG.randf_range(-force,force)
	var xf =  RNG.randf_range(-force,force)
	User.CameraOffset = Vector2(xf,yf)*0.5
	User.MoveCamera(Vector2(xf,yf))
