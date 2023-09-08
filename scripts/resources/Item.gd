extends Resource
class_name Item


@export var registry_name : String
@export var name : String
@export var description : String
@export var icon : Texture
@export var icon_offset: Vector2
@export var held_scene: PackedScene

func SaveItem():
	var dict = {}
	return dict
