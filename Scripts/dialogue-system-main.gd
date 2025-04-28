extends Control

var node_prefab = load("res://Prefabs/dialogue_node.tscn")

@export var save_path:String
@export var actor_popup:ActorPopup
@export var actor_data:ActorData
@export var node_dictionary:Dictionary


const node_min_width:int = 300
const node_min_height:int = 200

func _ready() -> void:
	actor_popup.disable_popup()
	$GraphEdit.add_valid_connection_type(0,1)
	$GraphEdit.add_valid_left_disconnect_type(0)
	$GraphEdit.add_valid_right_disconnect_type(1)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_mouse_press"):
		_add_new_dialogue_node()


func _on_graph_edit_connection_request(from_node:StringName, from_port:int, to_node:StringName, to_port:int) ->void:

	#Prevent to connect 2 slots in same node
	if from_node == to_node: return

	$GraphEdit.connect_node(from_node,from_port,to_node,to_port)

	var from_graph_node:DialogueNode
	var to_graph_node:DialogueNode

	if node_dictionary.has(from_node):
		from_graph_node = node_dictionary[from_node]

	if node_dictionary.has(to_node):
		to_graph_node = node_dictionary[to_node]

	#Save connected node id in each other node
	if from_graph_node!=null and to_graph_node!=null:
		from_graph_node.set_conneted_dialogue_id(to_graph_node.dialogue_id)
		to_graph_node.set_conneted_dialogue_id(from_graph_node.dialogue_id)


func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	$GraphEdit.disconnect_node(from_node,from_port,to_node,to_port)

	var from_graph_node:DialogueNode
	var to_graph_node:DialogueNode


	if node_dictionary.has(from_node):
		from_graph_node = node_dictionary[from_node]

	if node_dictionary.has(to_node):
		to_graph_node = node_dictionary[to_node]

	#Remove connectd node id
	if from_graph_node!=null and to_graph_node!=null:
		from_graph_node.remove_connected_dialogue_id()
		to_graph_node.remove_connected_dialogue_id()


func _on_actor_button_pressed() -> void:
	actor_popup.enable_popup()


func _add_new_dialogue_node():
	var instance = node_prefab.instantiate() as GraphNode
	instance.position_offset =  $GraphEdit.get_local_mouse_position() + $GraphEdit.scroll_offset/$GraphEdit.zoom
	
	var dialogue_id = _get_id()

	instance.initialize(dialogue_id, actor_data.actor_name_list)

	node_dictionary[instance.name] = instance

	$GraphEdit.add_child(instance)

func _add_dialogue_node(spawn_position:Vector2, dialogue_id:String,actor_name:String,dialogue:String,connected_node_id:String):
	var instance = node_prefab.instantiate() as GraphNode
	instance.position_offset = spawn_position + $GraphEdit.scroll_offset/$GraphEdit.zoom
	
	instance.fill_data(dialogue_id, actor_name, actor_data.actor_name_list, dialogue, connected_node_id)

	node_dictionary[instance.name] = instance

	$GraphEdit.add_child(instance)	

#region Export To JSON
func _export_dialogue():

	var dialogue_arr:Array

	var file = FileAccess.open(save_path + "dialogue.json",FileAccess.WRITE)
	for key in node_dictionary.keys():
		var dialogue_node = node_dictionary[key] as DialogueNode

		var raw_data:Dictionary ={
			"internal_position"			= "",
			"dialogue_id" 				= "",
			"actor_name"				= "",
			"dialogue" 					= "",
			"dialogue_connect_to_id" 	= ""
		}

		raw_data.internal_position = str(dialogue_node.position.x) + "," + str(dialogue_node.position.y)
		raw_data.dialogue_id = dialogue_node.dialogue_id
		raw_data.actor_name = dialogue_node.get_actor_name()
		raw_data.dialogue =  dialogue_node.get_dialogue()
		raw_data.dialogue_connect_to_id = dialogue_node.dialogue_connect_to_id

		dialogue_arr.push_back(raw_data)
	
	var json_data = JSON.stringify(dialogue_arr,"\t",false) #No sort
	file.store_line(json_data)
	file.close()

func _on_export_button_pressed() -> void:
	_export_dialogue()


#endregion



func _on_import_button_pressed() -> void:
	$FileDialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path,FileAccess.READ)
	var json_raw_text = JSON.parse_string(file.get_as_text())
	_import_json_file(json_raw_text)
	_set_connection_for_imported_node()


func _import_json_file(json_raw:Array):
	for index in json_raw.size():
		var data = json_raw[index]
		
		_add_dialogue_node(_json_string_to_vector2(data.internal_position) , 
							data.dialogue_id, 
							data.actor_name, 
							data.dialogue,
							data.dialogue_connect_to_id)

func _set_connection_for_imported_node():

	for key in node_dictionary.keys():
		var connected_id = node_dictionary[key].dialogue_connect_to_id
		for other_key in node_dictionary.keys():
			if node_dictionary[other_key].dialogue_id == connected_id:
				var from_node:String = "dialogue_node_" + node_dictionary[key].dialogue_id
				var to_node:String = "dialogue_node_" + node_dictionary[other_key].dialogue_id
				if !$GraphEdit.is_node_connected(from_node,0,to_node,0) and !$GraphEdit.is_node_connected(to_node,0,from_node,0): 
					$GraphEdit.connect_node(from_node,0,to_node,0)


func _get_id() -> String:
	var id = ""
	var rand_prefix = randi() % 129
	id += str(rand_prefix)

	var alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

	for i in range(0,10):
		var rand_char_index = randi() % alphabet.length()
		id += alphabet[rand_char_index]

	return id

func _json_string_to_vector2(value:String) -> Vector2:
	var arr = value.split(",")
	return Vector2( float(arr[0]),float(arr[1]))
