class_name DialogueNode extends BaseNode

@export var input_connect_id:String
@export var output_connect_id:String
@export var choice_id_1:String
@export var choice_id_2:String
@export var choice_id_3:String
@export var actor_list_button:OptionButton

@export var actor_name:String

func _ready() -> void:
	node_type = Helper.NODE_TYPE.DIALOGUE

func _on_tree_entered():
	var actor_popup = get_node("../../Actor-control") as ActorPopup
	actor_popup.on_add_new_actor.connect(_add_new_actor)
	actor_popup.on_remove_actor.connect(_remove_actor)


func fill_data(id:String,actor:String,actor_list:Array[String], dialogue:String,input_id:String, output_id:String, choice_1:String, choice_2:String, choice_3:String):
	name = Helper.get_node_name(id)
	node_id = id
	actor_name = actor
	input_connect_id = input_id
	output_connect_id = output_id
	choice_id_1 = choice_1
	choice_id_2 = choice_2
	choice_id_3 = choice_3

	_create_actor_option_list(actor_list)

	for index in actor_list.size():
		if actor == actor_list[index]:
			actor_list_button.selected = index


	$DialogueLabel/Dialogue.text = dialogue



func initialize(id:String, actor_list:Array[String]):
	self.name = Helper.get_node_name(id)
	node_id = id
	
	_create_actor_option_list(actor_list)

	#Default drop menu value will be at first item	
	actor_name = actor_list_button.get_item_text(0)


func _add_new_actor(actor_list:Array[String]):
	actor_list_button.clear()
	_create_actor_option_list(actor_list)

	#Set select actor back
	for index in actor_list.size():
		if actor_name == actor_list[index]:
			actor_list_button.selected = index


func _remove_actor(actor_list:Array[String]):
	actor_list_button.clear()
	_create_actor_option_list(actor_list)

	#Set select actor back
	for index in actor_list.size():
		if actor_name == actor_list[index]:
			actor_list_button.selected = index

func _create_actor_option_list(actor_list:Array[String]):
	for index in actor_list.size():
		actor_list_button.add_item(actor_list[index])

func set_input_connect_id(id:String):
	input_connect_id = id


func set_output_connect_id(id:String):
	output_connect_id = id


func remove_output_connect_id():
	output_connect_id = ""


func set_connect_choice_id(index:int,id:String):
	match index:
		0:
			input_connect_id = id
		1:
			choice_id_1 = id
		2:
			choice_id_2 = id
		3:
			choice_id_3 = id


func remove_connect_choice(index:int):
	match index:
		1:
			choice_id_1 = ""
		2:
			choice_id_2 = ""
		3:
			choice_id_3 = ""


func remove_connect_by_name(choice_node_name:String):
	if choice_id_1 == choice_node_name:
		choice_id_1 = ""
	elif choice_id_2 == choice_node_name:
		choice_id_2 = ""
	elif choice_id_3 == choice_node_name:
		choice_id_3 = ""


func get_dialogue() -> String:
	return $DialogueLabel/Dialogue.text

func _on_option_button_item_selected(index:int) -> void:
	actor_name = actor_list_button.get_item_text(index)


func delete_node():
	var parent_node = get_parent()

	if output_connect_id != "":
		var connect_dialogue_node = parent_node.get_node(Helper.get_node_name(output_connect_id)) as DialogueNode
		connect_dialogue_node.remove_output_connect_id()

	if choice_id_1!= "":
		var choice_node_1 = parent_node.get_node(Helper.get_node_name(choice_id_1)) as ChoiceNode
		choice_node_1.remove_input_dialogue()

	if choice_id_2!= "":
		var choice_node_2 = parent_node.get_node(Helper.get_node_name(choice_id_2)) as ChoiceNode
		choice_node_2.remove_input_dialogue()
	
	if choice_id_3!= "":
		var choice_node_3 = parent_node.get_node(Helper.get_node_name(choice_id_3)) as ChoiceNode
		choice_node_3.remove_input_dialogue()


	var actor_popup = get_node("../../Actor-control") as ActorPopup
	actor_popup.on_add_new_actor.disconnect(_add_new_actor)
	actor_popup.on_remove_actor.disconnect(_remove_actor)

	self.queue_free()


func setup_connection(graph:GraphEdit):
	if input_connect_id != "":
		graph.connect_node(self.name,0,Helper.get_node_name(input_connect_id), 0)
	if output_connect_id != "":
		graph.connect_node(self.name,0,Helper.get_node_name(output_connect_id), 0)
	if choice_id_1 != "":
		graph.connect_node(self.name,1,Helper.get_node_name(choice_id_1), 0)
	if choice_id_2 != "":
		graph.connect_node(self.name,2,Helper.get_node_name(choice_id_2), 0)
	if choice_id_3 != "":
		graph.connect_node(self.name,3,Helper.get_node_name(choice_id_2), 0)
