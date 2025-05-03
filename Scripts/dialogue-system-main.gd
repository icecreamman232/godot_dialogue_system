class_name DialogueSystem extends Control

var dialogue_node_prefab = load("res://Prefabs/dialogue_node.tscn")
var choice_node_prefab = load("res://Prefabs/choice_node.tscn")


@onready var export_module:ExportModule = $"Export-module"
@onready var import_module:ImportModule = $"Import-module"
@onready var graph:GraphEdit = $GraphEdit
@onready var right_click_menu:PanelContainer = $"Righ-click-menu"


@export var actor_popup:ActorPopup
@export var actor_data:ActorData
@export var node_dictionary:Dictionary

var current_selected_node:GraphNode


const DIALOGUE_CONNECTION_SLOT_LEFT_TYPE = 0
const DIALOGUE_CONNECTION_SLOT_RIGHT_TYPE = 1
const CHOICE_CONNECTION_SLOT_LEFT_TYPE = 2
const CHOICE_CONNECTION_SLOT_RIGHT_TYPE = 3

signal on_finish_export

func _ready() -> void:
	#Initialize EXPORT MODULE
	export_module.on_save_button_pressed.connect(_export_dialogue)
	import_module.on_import_file.connect(_on_file_dialog_file_selected)


	actor_popup.disable_popup()
	graph.add_valid_connection_type(0,1)
	graph.add_valid_left_disconnect_type(0)
	graph.add_valid_right_disconnect_type(1)
	graph.connection_request.connect(_on_graph_edit_connection_request)
	graph.disconnection_request.connect(_on_graph_edit_disconnection_request)
	graph.node_selected.connect(_on_select_node)
	graph.node_deselected.connect(_on_deselect_node)


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_DELETE):
		if current_selected_node!=null:
			_delete_node(current_selected_node)

#region Connecting Nodes

func _on_graph_edit_connection_request(from_node:StringName, from_port:int, to_node:StringName, to_port:int) ->void:

	#Prevent to connect 2 slots in same node
	if from_node == to_node: return

	var from_node_object = graph.get_node("./" + from_node)
	var to_node_object = graph.get_node("./" + to_node)

	if from_node_object is DialogueNode:
		if to_node_object is DialogueNode:
			_connect_dialogue_node_to_dialogue_node(from_node,from_port,to_node,to_port)
		else:
			_connect_dialogue_node_to_choice_node(from_node,from_port,to_node,to_port)
	else:
		if to_node_object is DialogueNode:
			_connect_choice_node_to_dialogue_node(from_node,from_port,to_node,to_port)



func _connect_dialogue_node_to_choice_node(from_node:StringName, from_port:int, to_node:StringName, to_port:int):

	var from_node_object = graph.get_node("./" + from_node) as DialogueNode
	var to_node_object = graph.get_node("./" + to_node) as ChoiceNode
	
	#Prevent connecting dialogue output port of dialogue node into choice node.
	#It's supposed to connect choice output port of dialogue node into choice node.
	var dialogue_output_port_type = from_node_object.get_output_port_type(from_port)
	if dialogue_output_port_type == 0: return


	#Save connected node id in each other node
	if from_node_object!=null and to_node_object!=null:
		from_node_object.set_connect_choice_id(from_port,to_node_object.choice_id)
		to_node_object.set_input_dialogue(from_node_object.dialogue_id)

	graph.connect_node(from_node,from_port,to_node,to_port)


func _connect_choice_node_to_dialogue_node(from_node:StringName, from_port:int, to_node:StringName, to_port:int):

	
	var from_node_object = graph.get_node("./" + from_node) as ChoiceNode
	var to_node_object = graph.get_node("./" + to_node) as DialogueNode
	
	#Save connected node id in each other node
	if from_node_object!=null and to_node_object!=null:
		from_node_object.set_output_dialogue(to_node_object.dialogue_id)
		to_node_object.set_connect_choice_id(to_port,from_node_object.choice_id)


	graph.connect_node(from_node,from_port,to_node,to_port)

func _connect_dialogue_node_to_dialogue_node(from_node:StringName, from_port:int,to_node:StringName, to_port:int):

	graph.connect_node(from_node,from_port,to_node,to_port)

	var from_node_object = graph.get_node("./" + from_node) as DialogueNode
	var to_node_object = graph.get_node("./" + to_node) as DialogueNode
	
	#Save connected node id in each other node
	if from_node_object!=null and to_node_object!=null:
		from_node_object.set_conneted_dialogue_id(to_node_object.dialogue_id)
		to_node_object.set_conneted_dialogue_id(from_node_object.dialogue_id)

#endregion


#region Disconnecting Nodes
func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var from_node_object = graph.get_node("./" + from_node)
	var to_node_object = graph.get_node("./" + to_node)

	if from_node_object is DialogueNode:
		if to_node_object is DialogueNode:
			_disconnect_from_dialogue_node_to_dialogue_node(from_node,from_port,to_node,to_port)
		else:
			_disconnect_from_dialogue_node_to_choice_node(from_node,from_port,to_node,to_port)
	else:
		if to_node_object is DialogueNode:
			_disconnect_from_choice_node_to_dialogue_node(from_node,from_port,to_node,to_port)
	

func _disconnect_from_dialogue_node_to_dialogue_node(from_node: StringName, from_port: int, to_node: StringName, to_port: int):

	graph.disconnect_node(from_node,from_port,to_node,to_port)

	var from_node_object = graph.get_node("./" + from_node) as DialogueNode
	var to_node_object = graph.get_node("./" + to_node) as DialogueNode

	if from_node_object!=null and to_node_object!=null:
		from_node_object.remove_connected_dialogue_id()
		to_node_object.remove_connected_dialogue_id()


func _disconnect_from_dialogue_node_to_choice_node(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	graph.disconnect_node(from_node,from_port,to_node,to_port)

	var from_node_object = graph.get_node("./" + from_node) as DialogueNode
	var to_node_object = graph.get_node("./" + to_node) as ChoiceNode

	if from_node_object!=null and to_node_object!=null:
		from_node_object.remove_connect_choice(from_port)
		to_node_object.remove_input_dialogue()


func _disconnect_from_choice_node_to_dialogue_node(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	graph.disconnect_node(from_node,from_port,to_node,to_port)

	var from_node_object = graph.get_node("./" + from_node) as ChoiceNode
	var to_node_object = graph.get_node("./" + to_node) as DialogueNode

	if from_node_object!=null and to_node_object!=null:
		from_node_object.remove_output_dialogue()
		to_node_object.remove_connect_choice(to_port)

#endregion



func _on_actor_button_pressed() -> void:
	actor_popup.enable_popup()


func add_new_dialogue_node():
	var instance = dialogue_node_prefab.instantiate() as GraphNode
	instance.position_offset = graph.get_local_mouse_position() + graph.scroll_offset/graph.zoom
	
	var dialogue_id = _get_id()

	instance.initialize(dialogue_id, actor_data.actor_name_list)

	node_dictionary[instance.name] = instance

	graph.add_child(instance)


func _add_dialogue_node(spawn_position:Vector2, dialogue_id:String,actor_name:String,dialogue:String,input_id:String, output_id:String, choice_1:String, choice_2:String, choice_3:String):
	var instance = dialogue_node_prefab.instantiate() as GraphNode
	instance.position_offset = spawn_position + graph.scroll_offset/graph.zoom
	
	graph.add_child(instance)	

	(instance as DialogueNode).fill_data(dialogue_id, actor_name, actor_data.actor_name_list, dialogue,input_id, output_id,choice_1,choice_2,choice_3)
	node_dictionary[instance.name] = instance


func add_new_choice_node():
	var instance = choice_node_prefab.instantiate() as GraphNode
	instance.position_offset = graph.get_local_mouse_position() + graph.scroll_offset/graph.zoom
	
	var choice_id = _get_id()

	(instance as ChoiceNode).initialize(choice_id)

	node_dictionary[instance.name] = instance

	
	graph.add_child(instance)	


func add_new_choice_from_file(spawn_position:Vector2, choice_id:String, input_id:String,output_id:String,dialogue:String):
	var instance = choice_node_prefab.instantiate() as GraphNode
	instance.position_offset = spawn_position + graph.scroll_offset/graph.zoom
	
	(instance as ChoiceNode).initialize(choice_id, input_id, output_id, dialogue)

	node_dictionary[instance.name] = instance

	graph.add_child(instance)


#region Export To JSON
func _export_dialogue(save_path:String):
	var data_array:Array

	var file = FileAccess.open(save_path,FileAccess.WRITE)
	for key in node_dictionary.keys():
		var data_node = node_dictionary[key]

		if data_node is DialogueNode:
			var  raw_data = _export_raw_data_of_dialogue_node(data_node)
			data_array.push_back(raw_data)
		elif data_node is ChoiceNode:
			var  raw_data = _export_raw_data_of_choice_node(data_node)
			data_array.push_back(raw_data)



	var json_data = JSON.stringify(data_array,"\t",false) #No sort
	file.store_line(json_data)
	file.close()

	on_finish_export.emit("The dialogue has been saved to " + save_path)


func _export_raw_data_of_dialogue_node(dialogue_node:DialogueNode) -> Dictionary:
	var raw_data:Dictionary ={
			"internal_position"			= "",
			"node_type"					= "",
			"dialogue_id" 				= "",
			"actor_name"				= "",
			"dialogue" 					= "",
			"input_connect_id" 			= "",
			"output_connect_id" 		= "",
			"choice_id_1"				= "",
			"choice_id_2"				= "",
			"choice_id_3"				= ""
		}

	raw_data.internal_position = str(dialogue_node.position.x) + "," + str(dialogue_node.position.y)
	raw_data.node_type = dialogue_node.node_type
	raw_data.dialogue_id = dialogue_node.dialogue_id
	raw_data.actor_name = dialogue_node.get_actor_name()
	raw_data.dialogue =  dialogue_node.get_dialogue()
	raw_data.input_connect_id = dialogue_node.input_connect_id
	raw_data.output_connect_id = dialogue_node.output_connect_id
	raw_data.choice_id_1 =	dialogue_node.choice_id_1
	raw_data.choice_id_1 =	dialogue_node.choice_id_1
	raw_data.choice_id_1 =	dialogue_node.choice_id_1
	return raw_data


func _export_raw_data_of_choice_node(choice_node:ChoiceNode):
	var raw_data:Dictionary ={
			"internal_position"			= "",
			"node_type"					= "",
			"choice_id" 				= "",
			"input_dialogue_id"			= "",
			"output_dialogue_id" 		= "",
			"dialogue"					= ""
		}

	raw_data.internal_position = str(choice_node.position.x) + "," + str(choice_node.position.y)
	raw_data.node_type = choice_node.node_type
	raw_data.choice_id = choice_node.choice_id
	raw_data.input_dialogue_id = choice_node.input_dialogue_id
	raw_data.output_dialogue_id =  choice_node.output_dialogue_id
	raw_data.dialogue =  choice_node.get_dialogue()
	return raw_data

#endregion


func _delete_node(to_delete_node:Node):
	node_dictionary.erase(to_delete_node.name)
	to_delete_node.delete()

func _on_select_node(select_node:Node):
	current_selected_node = select_node	as GraphNode


func _on_deselect_node(deselect_node:Node):
	current_selected_node = null



func _on_file_dialog_file_selected(path: String) -> void:
	_clear_current_graph()
	var file = FileAccess.open(path,FileAccess.READ)
	var json_raw_text = JSON.parse_string(file.get_as_text())
	_import_json_file(json_raw_text)
	_set_connection_for_imported_node()

func _clear_current_graph():
	for key in node_dictionary.keys():
		node_dictionary[key].queue_free()

	node_dictionary.clear()
	

func _import_json_file(json_raw:Array):
	for index in json_raw.size():
		var data = json_raw[index]
		
		match data.node_type as int:
			0:
				_add_dialogue_node(_json_string_to_vector2(data.internal_position) , 
								data.dialogue_id, 
								data.actor_name, 
								data.dialogue,
								data.input_connect_id,
								data.output_connect_id,
								data.choice_id_1,
								data.choice_id_2,
								data.choice_id_3)
			1:
				add_new_choice_from_file(_json_string_to_vector2(data.internal_position),
										data.choice_id,
										data.input_dialogue_id,
										data.output_dialogue_id,
										data.dialogue)



func _set_connection_for_imported_node():
	for key in node_dictionary.keys():
		node_dictionary[key]._setup_connection(graph)
			


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
