extends Resource
class_name Registry


@export var values : Dictionary


func AddValue(name,path):
	values[name] = path
func GetValue(name):
	if values.has(name):
		return values[name]
	else:
		print("no value with key " + name)
		return null
func RemoveValue(name):
	if values.has(name):
		values.erase(name)
	else:
		print("no value with key " + name)
