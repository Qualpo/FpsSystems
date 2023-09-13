extends Item
class_name Gun

@export var max_ammo :int = 0
@export var ammo :int = 0
@export_range(0,1) var accuracy = 1.0
@export var shoot_cooldown = 0.1
@export var recoil = 3.0
@export var bullet_ammount = 1
@export var shoot_sound : AudioStream
@export var no_bullet_sound : AudioStream
@export var aim_zoom = 0.0

func SaveItem():
	var dict = {}
	dict["ammo"] = ammo
	return dict
