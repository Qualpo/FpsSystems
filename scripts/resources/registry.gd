extends Resource
class_name Registry


@export var entries = {}


func AddEntry(key,value):
	entries[key] = value
	
func GetValue(key):
	if entries.has(key):
		return entries[key]
	else:
		print("no value with key " + key)
		return null

func RemoveEntry(key):
	if entries.has(key):
		entries.erase(key)
	else:
		print("no value with key " + key)
