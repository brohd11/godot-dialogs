@tool
#! namespace Dialogs.Handlers class Confirmation
extends Dialogs.Base.Handler


static func confirm(message_text:String, dialog_parent=null) -> bool:
	var handler = new(message_text, dialog_parent)
	var resp:Dialogs.Response = await handler.handled
	return resp.cancelled or (resp.payload is bool and resp.payload)

static func acknowledge(message_text:String, dialog_parent=null) -> bool:
	var handler = new(message_text, dialog_parent)
	handler.is_acknowledge()
	var resp:Dialogs.Response = await handler.handled
	return true


var cancel_button:Button

func _init(dialog_text, _root_node=null) -> void:
	_set_root_node(_root_node)
	_create_dialog(dialog_text)



func _create_dialog(dialog_text) -> void:
	dialog = ConfirmationDialog.new()
	dialog.confirmed.connect(_on_confirmed)
	dialog.canceled.connect(_on_canceled)
	
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	cancel_button = dialog.get_cancel_button()
	
	var ok_button = dialog.get_ok_button()
	ok_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var label = dialog.get_label()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	dialog.dialog_text = dialog_text
	root_node.add_child(dialog)
	dialog.show()
	
	ok_button.focus_mode = Control.FOCUS_NONE
	cancel_button.focus_mode = Control.FOCUS_NONE

func is_acknowledge():
	cancel_button.hide()

func non_exclusive():
	dialog.exclusive = false

func _on_confirmed():
	_emit_handled(true)
	
func _on_canceled():
	_emit_handled(false)
