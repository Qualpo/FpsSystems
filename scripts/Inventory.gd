extends Node

var Items : Array[Item]
var CurItem = -1

#Registry Name
var StartingItems : Array[String] = [
	
]

signal ItemChanged(item:Item)


func _ready():
	for i in StartingItems:
		var item = Global.ItemRegistry.GetValue(i)
		if item != null:
			Items.append(load(item))

func Unequip():
	CurItem = -1
	ItemChanged.emit(null)
func SelectItem(index:int):
	if index < Items.size() and index >= -1:
		CurItem = index
		ItemChanged.emit(Items[index])
func AddItem(item:Item):
	if item != null:
		Items.append(item)
		if Items.size() == 1:
			SelectItem(0)
func RemoveItem(item:Item):
	if Items.has(item):
		Items.erase(item)
func RemoveItemAtIndex(index:int):
	if index < Items.size() and index >= 0:
		if index == Items.size() -1:
			if CurItem == index:
				CurItem -= 1
		Items.remove_at(index)
func _input(event):
	if event.is_action_pressed("ScrollUp"):
		var nitem = CurItem + 1
		if nitem >= Items.size():
			nitem = 0
		SelectItem(nitem)
	elif event.is_action_pressed("ScrollDown"):
		var nitem = CurItem - 1
		if nitem < 0:
			nitem = Items.size()-1
		SelectItem(nitem)
