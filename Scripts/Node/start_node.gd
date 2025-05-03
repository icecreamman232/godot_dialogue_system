class_name StartNode extends BaseNode

@export var output_connect_id:String


func _ready() -> void:
    node_type = Helper.NODE_TYPE.START
    node_id = Helper.get_id()