extends Node

var Items : Array[Item]
var CurItem = -1

signal ItemChanged(item:Item)

func Unequip():
	CurItem = -1
	ItemChanged.emit(null)
func SelectItem(index:int):
	if index < Items.size() and index >= 0:
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
