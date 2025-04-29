class_name ImportModule extends Control

@onready var import_button:Button = $"../ImportButton"
@onready var import_file_dialog:FileDialog = $"../ImportFileDialog"


signal on_import_button_pressed
signal on_import_file(file_path:String)


func _ready() -> void:
    import_button.pressed.connect(_import_button_pressed)
    import_file_dialog.file_selected.connect(_import_file)


func _exit_tree() -> void:
    import_button.pressed.disconnect(_import_button_pressed)
    import_file_dialog.file_selected.disconnect(_import_file)

func _import_button_pressed():
    import_file_dialog.popup()


func _import_file(path:String):
    on_import_file.emit(path)
