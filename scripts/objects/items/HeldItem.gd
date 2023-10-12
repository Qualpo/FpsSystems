extends Node3D
class_name HeldItem

var item : Item
var User = null

func _ready():
	$PreviewCamera.queue_free()

func Hold(user,item):
	User = user
	self.item = item
	user.connect("use",Use)
	user.connect("unuse",UnUse)
	user.connect("secondaryuse",SecondaryUse)
	user.connect("secondaryunuse",SecondaryUnUse)
func UnHold():
	User.disconnect("use",Use)
	User.disconnect("unuse",UnUse)
	User.disconnect("secondaryuse",SecondaryUse)
	User.disconnect("secondaryunuse",SecondaryUnUse)
	queue_free()
func Use():
	pass
func UnUse():
	pass
func SecondaryUse():
	pass
func SecondaryUnUse():
	pass
