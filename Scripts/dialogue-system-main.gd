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


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_mouse_press"):
		#add_new_dialogue_node()
		right_click_menu.position = get_global_mouse_position()

func _on_graph_edit_connection_request(from_node:StringName, from_port:int, to_node:StringName, to_port:int) ->void:

	#Prevent to connect 2 slots in same node
	if from_node == to_node: return

	graph.connect_node(from_node,from_port,to_node,to_port)

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
	graph.disconnect_node(from_node,from_port,to_node,to_port)

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


func add_new_dialogue_node():
	var instance = dialogue_node_prefab.instantiate() as GraphNode
	instance.position_offset = graph.get_local_mouse_position() + graph.scroll_offset/graph.zoom
	
	var dialogue_id = _get_id()

	instance.initialize(dialogue_id, actor_data.actor_name_list)

	node_dictionary[instance.name] = instance

	graph.add_child(instance)



func _add_dialogue_node(spawn_position:Vector2, dialogue_id:String,actor_name:String,dialogue:String,connected_node_id:String):
	var instance = dialogue_node_prefab.instantiate() as GraphNode
	instance.position_offset = spawn_position + graph.scroll_offset/graph.zoom
	
	graph.add_child(instance)	

	(instance as DialogueNode).fill_data(dialogue_id, actor_name, actor_data.actor_name_list, dialogue, connected_node_id)
	node_dictionary[instance.name] = instance


func add_choice_node():
	var instance = choice_node_prefab.instantiate() as GraphNode
	instance.position_offset = graph.get_local_mouse_position() + graph.scroll_offset/graph.zoom
	
	graph.add_child(instance)	


#region Export To JSON
func _export_dialogue(save_path:String):
	var dialogue_arr:Array

	var file = FileAccess.open(save_path,FileAccess.WRITE)
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

	on_finish_export.emit("The dialogue has been saved to " + save_path)


#endregion



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
				if !graph.is_node_connected(from_node,0,to_node,0) and !graph.is_node_connected(to_node,0,from_node,0): 
					graph.connect_node(from_node,0,to_node,0)


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
