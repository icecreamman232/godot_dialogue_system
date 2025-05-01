class_name RightClickMenu extends PanelContainer

@onready var create_dialogue_button:Button = $"Control/dialogue-node-button"
@onready var create_choice_button:Button = $"Control/choice-node-button"
@onready var dialogue_system:DialogueSystem = $".."



func _ready() -> void:
    create_dialogue_button.pressed.connect(_on_create_dialogue_button_pressed)
    create_choice_button.pressed.connect(_on_create_choice_button_pressed)
    _hide()


func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_action_pressed("right_mouse_press"):
            self.position = get_global_mouse_position()
            _show()

        #Try to hide menu if user click outside the menu
        if event.is_action_pressed("left_mouse_press"):
            var localInput = create_dialogue_button.make_input_local(event)
            if !create_dialogue_button.get_rect().has_point(localInput.position) and !create_choice_button.get_rect().has_point(localInput.position):
                _hide()


func _show():
    self.visible = true



func _hide():
    self.visible = false


func _on_create_dialogue_button_pressed():
    dialogue_system.add_new_dialogue_node()
    _hide()


func _on_create_choice_button_pressed():
    dialogue_system.add_choice_node()
    _hide()
