class_name ChoiceNode extends GraphNode

@export var choice_id:String
@export var input_dialogue_id:String
@export var output_dialogue_id:String


func initialize(id:String, input_dialogue:String = "", output_dialogue:String = ""):
    choice_id = id
    name = "choice_node_" + choice_id
    input_dialogue_id = input_dialogue
    output_dialogue_id = output_dialogue


func set_input_dialogue(id:String):
    input_dialogue_id = id


func set_output_dialogue(id:String):
    output_dialogue_id = id


func remove_input_dialogue():
    input_dialogue_id = ""


func remove_output_dialogue():
    output_dialogue_id = ""