class_name ChoiceNode extends BaseNode

@export var input_dialogue_id:String
@export var output_dialogue_id:String
@export var dialogue:String


func _ready() -> void:
    node_type = Helper.NODE_TYPE.CHOICE

func initialize(id:String, input_dialogue:String = "", output_dialogue:String = "", _dialogue:String = ""):
    node_id = id
    name = Helper.get_node_name(id)
    input_dialogue_id = input_dialogue
    output_dialogue_id = output_dialogue
    dialogue = _dialogue


func get_dialogue() -> String:
    dialogue = $Label/TextEdit.text
    return dialogue

func set_input_dialogue(id:String):
    input_dialogue_id = id


func set_output_dialogue(id:String):
    output_dialogue_id = id


func remove_input_dialogue():
    input_dialogue_id = ""


func remove_output_dialogue():
    output_dialogue_id = ""


func delete_node():

    var graph = get_parent()
    
    if input_dialogue_id !="" :
        var input_node = graph.get_node(Helper.get_node_name(input_dialogue_id)) as DialogueNode
        input_node.remove_connect_by_name(node_id)
        remove_input_dialogue()
    
    if output_dialogue_id != "":
        var output_node = graph.get_node(Helper.get_node_name(output_dialogue_id)) as DialogueNode
        output_node.remove_connect_by_name(node_id)
        remove_output_dialogue()

    self.queue_free()
