class_name ActorPopup extends Control

@export var input_box:LineEdit
@export var add_button:Button

var container:VBoxContainer
var actor_data:ActorData = load("res://Data/actor-data.tres")
var actor_name_element_prefab = load("res://Prefabs/actor_name_container_element.tscn")

signal on_add_new_actor(actor_list:Array[String])
signal on_remove_actor(actor_list:Array[String])


func _ready() -> void:
	container = $PanelContainer.get_node("Actor-name-container")
	input_box.text_submitted.connect(_submit_new_actor_name)
	add_button.pressed.connect(_add_button_pressed)


func _add_button_pressed():
	if input_box.text == "": return
	_submit_new_actor_name(input_box.text)

func _submit_new_actor_name(new_text:String) -> void:

	for actor_name in actor_data.actor_name_list:
		if actor_name == new_text:
			return

	actor_data.actor_name_list.push_back(new_text)
	_add_actor_name_to_container(new_text)

	input_box.text = ""
	ResourceSaver.save(actor_data,"res://Data/actor-data.tres")
	on_add_new_actor.emit(actor_data.actor_name_list)

func _on_close_button_pressed() -> void:
	disable_popup()


func disable_popup():
	_clear_container()

	input_box.editable = false
	add_button.disabled = true

	self.visible = false


func enable_popup():

	_fill_actor_name_list()

	input_box.editable = true
	add_button.disabled = false

	self.visible = true


func _add_actor_name_to_container(actor_name:String):
	var newElement = actor_name_element_prefab.instantiate() as Label
	newElement.text = actor_name
	newElement.on_remove_actor_name_element.connect(_on_remove_actor_name_element)
	container.add_child(newElement)
	

func _on_remove_actor_name_element(element:ActorNameElement,actor_name:String):
	element.on_remove_actor_name_element.disconnect(_on_remove_actor_name_element)

	#Find the index of actor name which is supposed to be removed
	var index_to_remove = -1
	for index in actor_data.actor_name_list.size():
		if actor_data.actor_name_list[index] == actor_name:
			index_to_remove = index
	
	#Try to remove the actor name
	if index_to_remove != -1:
		actor_data.actor_name_list.remove_at(index_to_remove)


	on_remove_actor.emit(actor_data.actor_name_list)


	ResourceSaver.save(actor_data,"res://Data/actor-data.tres")


func _fill_actor_name_list():
	for actor_name in actor_data.actor_name_list:
		_add_actor_name_to_container(actor_name)


func _clear_container():
	var child_count =  container.get_child_count()
	if child_count <= 0: return

	for i in range(0,child_count):
		var child = container.get_child(i) as Control
		child.queue_free()
