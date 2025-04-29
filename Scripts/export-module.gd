class_name ExportModule extends Control

@onready var export_file_dialog:FileDialog = $"../ExportFileDialog"
@onready var export_confirm_popup:AcceptDialog = $"../ExportAcceptDialog"
@onready var export_button:Button = $"../ExportButton"
@onready var dialogue_sytem:DialogueSystem = $".."
@export var last_save_path:String

signal on_save_button_pressed(save_path:String)

func _ready() -> void:
    export_button.pressed.connect(_on_export_button_pressed)
    export_file_dialog.file_selected.connect(_on_export_file_dialog_confirm_pressed)
    export_confirm_popup.confirmed.connect(_on_close_confirm_export)
    
    dialogue_sytem.on_finish_export.connect(_on_confirm_export)


func _exit_tree() -> void:
    export_file_dialog.confirmed.disconnect(_on_export_file_dialog_confirm_pressed)
    export_confirm_popup.confirmed.disconnect(_on_confirm_export)
    export_button.pressed.disconnect(_on_export_button_pressed)


##Call when player press export button. The export dialog will be shown
func _on_export_button_pressed():
    export_file_dialog.popup()


##Call when players press open/save button in export dialog
func _on_export_file_dialog_confirm_pressed(path:String):
  
    on_save_button_pressed.emit(path)

    last_save_path = export_file_dialog.current_path



##Call when player press OK/Accept on confirm box after exporting done
func _on_confirm_export(message:String):
    export_confirm_popup.visible = true
    export_confirm_popup.get_child(0).text = message


func _on_close_confirm_export():
    export_confirm_popup.visible = false
