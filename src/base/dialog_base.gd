#! namespace Dialogs.Base class Handler
extends RefCounted

const Response = Dialogs.Response

var root_node:Node
var dialog:Node

var _handled:bool=false
signal handled(response:Response)

func _set_root_node(_root_node):
	if _root_node == null:
		if Engine.is_editor_hint():
			var ed_int = Engine.get_singleton(&"EditorInterface")
			_root_node = ed_int.get_base_control()
		else:
			_root_node = Engine.get_main_loop().root
	root_node = _root_node

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(dialog):
			dialog.queue_free()


func _emit_handled(payload:Variant) -> void:
	if _is_handled():
		return
	
	var r:= Response.new()
	r.payload = payload
	handled.emit(r)
	_free_dialog()
	

func _emit_cancel() -> void:
	if _is_handled():
		return
	
	var r:= Response.new()
	r.cancelled = true
	handled.emit(r)
	_free_dialog()

func _is_handled():
	if _handled:
		_free_dialog()
		return true
	_handled = true
	return false

func _free_dialog():
	if is_instance_valid(dialog):
		dialog.queue_free()
