class_name Helper extends Node


enum NODE_TYPE {START, DIALOGUE, CHOICE}


##Convert dialogue node id to node name
static func get_node_name(id:String) -> String:
    return "node_" + id


static func get_id() -> String:
    var id = ""
    var rand_prefix = randi() % 129
    id += str(rand_prefix)
    var alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

    for i in range(0,10):
        var rand_char_index = randi() % alphabet.length()
        id += alphabet[rand_char_index]
    return id
