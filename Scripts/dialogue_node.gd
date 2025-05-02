class_name DialogueNode extends GraphNode

@export var dialogue_id:String
@export var dialogue_connect_to_id:String
@export var choice_id_1:String
@export var choice_id_2:String
@export var choice_id_3:String
@export var actor_list_button:OptionButton

@export var actor_name:String


func fill_data(id:String,actor:String,actor_list:Array[String], dialogue:String, connected_node_id:String):
	name = "dialogue_node_" + id
	dialogue_id = id
	actor_name = actor
	dialogue_connect_to_id = connected_node_id

	for index in actor_list.size():
		actor_list_button.add_item(actor_list[index])
		if actor == actor_list[index]:
			actor_list_button.selected = index


	$DialogueLabel/Dialogue.text = dialogue

func initialize(id:String, actor_list:Array[String]):
	self.name = "dialogue_node_" + id
	dialogue_id = id
	for actor in actor_list:
		actor_list_button.add_item(actor)

	#Default drop menu value will be at first item	
	actor_name = actor_list_button.get_item_text(0)

	

func set_conneted_dialogue_id(id:String):
	dialogue_connect_to_id = id


func remove_connected_dialogue_id():
	dialogue_connect_to_id = ""


func set_connect_choice_id(index:int,id:String):
	match index:
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

func get_actor_name() -> String:
	return actor_name

func get_dialogue() -> String:
	return $DialogueLabel/Dialogue.text

func _on_option_button_item_selected(index:int) -> void:
	actor_name = actor_list_button.get_item_text(index)


func delete():
	var parent_node = get_parent()

	if dialogue_connect_to_id != "":
		var connect_dialogue_node = parent_node.get_node("dialogue_node_" + dialogue_connect_to_id) as DialogueNode
		connect_dialogue_node.remove_connected_dialogue_id()

	if choice_id_1!= "":
		var choice_node_1 = parent_node.get_node("choice_node_" + choice_id_1) as ChoiceNode
		choice_node_1.remove_input_dialogue()

	if choice_id_2!= "":
		var choice_node_2 = parent_node.get_node("choice_node_" + choice_id_2) as ChoiceNode
		choice_node_2.remove_input_dialogue()
	
	if choice_id_3!= "":
		var choice_node_3 = parent_node.get_node("choice_node_" + choice_id_3) as ChoiceNode
		choice_node_3.remove_input_dialogue()

	self.queue_free()
