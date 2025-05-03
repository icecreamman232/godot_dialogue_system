class_name Helper extends Node


enum NODE_TYPE {DIALOGUE, CHOICE}


##Convert dialogue node id to node name
static func get_dialogue_node_name(id:String) -> String:
    return "node_" + id

