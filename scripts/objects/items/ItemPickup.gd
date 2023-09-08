extends Area3D


@export var item : Item

func Interact(interactor):
	Inventory.AddItem(item.duplicate())
	queue_free()
