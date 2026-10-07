#! namespace Dialogs.Handlers class FilePicker

#! keys i-Settings.create;
static func with_params(params:Dictionary={}):
	var settings = Settings.create(params)
	return FileBase.new(settings)


static func file(settings:Settings=null):
	settings = Settings.validate_ins(settings)
	settings.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	return FileBase.new(settings)

static func files(settings:Settings=null):
	settings = Settings.validate_ins(settings)
	settings.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	return FileBase.new(settings)

static func dir(settings:Settings=null):
	settings = Settings.validate_ins(settings)
	settings.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	return FileBase.new(settings)

static func any(settings:Settings=null):
	settings = Settings.validate_ins(settings)
	settings.file_mode = FileDialog.FILE_MODE_OPEN_ANY
	return FileBase.new(settings)

static func save(settings:Settings=null):
	settings = Settings.validate_ins(settings)
	settings.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	return FileBase.new(settings)


class Settings:
	var root_node = null
	var editor_dialog:= false
	var current_path:String = ""
	var access_mode:FileDialog.Access = FileDialog.ACCESS_FILESYSTEM
	var file_mode:FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_FILE
	var do_display:=true
	
	func _init(
		path:String="",
		_access_mode:FileDialog.Access = FileDialog.ACCESS_FILESYSTEM,
		_file_mode:FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_FILE,
		_editor_dialog:=false
		):
		current_path = path
		access_mode = _access_mode
		file_mode = _file_mode
		editor_dialog = _editor_dialog
	
	#! keys editor_dialog:bool current_path:String access_mode:int file_mode:int do_display:bool
	static func create(params:={}):
		var ins = new()
		for p in params.keys():
			ins.set(p, params[p])
		return ins
	
	static func validate_ins(settings):
		if settings == null:
			settings = new()
		return settings

class FileBase extends Dialogs.Base.Handler:
	
	var settings:Settings
	
	func _init(_settings:Settings) -> void:
		settings = _settings
		_set_root_node(settings.root_node)
		if settings.do_display:
			display()
	
	func display():
		if not Engine.is_editor_hint() and settings.editor_dialog:
			printerr("Cannot instance EditorFileDialog without editor. Instancing standard FileDialog")
			settings.editor_dialog = false
		
		if settings.editor_dialog:
			dialog = ClassDB.instantiate(&"EditorFileDialog")
		else:
			dialog = ClassDB.instantiate(&"FileDialog")
		
		if settings.current_path != "":
			dialog.current_path = ProjectSettings.globalize_path(settings.current_path)
		
		dialog.access = settings.access_mode
		dialog.file_mode = settings.file_mode
		
		if dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILE:
			dialog.file_selected.connect(_on_confirmed)
		if dialog.file_mode == FileDialog.FILE_MODE_OPEN_FILES:
			dialog.file_selected.connect(_on_confirmed)
			dialog.files_selected.connect(_on_confirmed)
		elif dialog.file_mode == FileDialog.FILE_MODE_OPEN_DIR:
			dialog.dir_selected.connect(_on_confirmed)
		elif dialog.file_mode == FileDialog.FILE_MODE_OPEN_ANY:
			dialog.dir_selected.connect(_on_confirmed)
			dialog.file_selected.connect(_on_confirmed)
		elif dialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
			dialog.file_selected.connect(_on_confirmed)
		
		dialog.canceled.connect(_on_canceled)
		
		root_node.add_child(dialog)
		dialog.popup_file_dialog()
		
		var cancel_button = dialog.get_cancel_button()
		cancel_button.focus_mode = Control.FOCUS_NONE
		var ok_button = dialog.get_ok_button()
		ok_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ok_button.focus_mode = Control.FOCUS_NONE


	func _on_confirmed(path):
		_emit_handled(path)

	func _on_canceled():
		_emit_cancel()
