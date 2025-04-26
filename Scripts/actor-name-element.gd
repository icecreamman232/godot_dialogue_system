class_name ActorNameElement extends Node

@export var actor_label:Label

signal on_remove_actor_name_element(actor_name:String)

func _on_removebutton_pressed() -> void:
	on_remove_actor_name_element.emit(self, actor_label.text)
	queue_free()
