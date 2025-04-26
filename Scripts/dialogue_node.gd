class_name DialogueNode extends GraphNode

@export var dialogue_id:String
@export var dialogue_connect_to_id:String
@export var actor_list_button:OptionButton


func initialize(actor_list:Array[String]):
	dialogue_id = _get_id()
	for actor in actor_list:
		actor_list_button.add_item(actor)


func set_conneted_dialogue_id(id:String):
	dialogue_connect_to_id = id


func _remove_connected_dialogue_id():
	dialogue_connect_to_id = ""


func _get_id() -> String:
	var id = ""
	var rand_prefix = randi() % 129
	id += str(rand_prefix)

	var alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	for i in range(0,10):
		var rand_char_index = randi() % alphabet.length()
		id += alphabet[rand_char_index]

	return id
