extends Control

var node_prefab = load("res://Prefabs/dialogue_node.tscn")

@export var save_path:String
@export var actor_popup:ActorPopup
@export var actor_data:ActorData
@export var node_list:Array[GraphNode]


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


	for i in node_list.size():
		if node_list[i].name == from_node:
			from_graph_node = node_list[i]

	for i in node_list.size():
		if node_list[i].name == to_node:
			to_graph_node = node_list[i]

	if from_graph_node!=null and to_graph_node!=null:
		from_graph_node.set_conneted_dialogue_id(to_graph_node.dialogue_id)
		to_graph_node.set_conneted_dialogue_id(from_graph_node.dialogue_id)



func _on_graph_edit_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	$GraphEdit.disconnect_node(from_node,from_port,to_node,to_port)

	var from_graph_node:DialogueNode
	var to_graph_node:DialogueNode

	for i in node_list.size():
		if node_list[i].name == from_node:
			from_graph_node = node_list[i]

	for i in node_list.size():
		if node_list[i].name == to_node:
			to_graph_node = node_list[i]

	if from_graph_node!=null and to_graph_node!=null:
		from_graph_node.remove_connected_dialogue_id()
		to_graph_node.remove_connected_dialogue_id()


func is_node_name(current_node:GraphNode, node_name_to_compare:String) -> bool:
	return current_node.name == node_name_to_compare


func _on_actor_button_pressed() -> void:
	actor_popup.enable_popup()


func _add_new_dialogue_node():
	var instance = node_prefab.instantiate() as GraphNode
	instance.position_offset =  $GraphEdit.get_local_mouse_position() + $GraphEdit.scroll_offset/$GraphEdit.zoom
	
	instance.initialize(actor_data.actor_name_list)

	node_list.push_back(instance)

	$GraphEdit.add_child(instance)


func _export_dialogue():

	var dialogue_arr:Array

	var file = FileAccess.open(save_path + "dialogue.json",FileAccess.WRITE)
	for index in node_list.size():
		var dialogue_node = node_list[index] as DialogueNode

		var raw_data:Dictionary ={
			"dialogue_id" 				= "",
			"actor_name"				= "",
			"dialogue" 					= "",
			"dialogue_connect_to_id" 	= ""
		}
		
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
