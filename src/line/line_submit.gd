#! namespace Dialogs.Handlers class LineSubmit
extends Dialogs.Base.Handler


const UWindow = preload("uid://d1yl3cuumcudy") #! resolve UtilR.Nodes.UWindow
const PathHelper = preload("uid://ba5x2r7gyvmej") #! resolve UtilR.Nodes.PopupMenus.PathHelper
const MouseHelper = PathHelper.MouseHelper

enum SelectMode {
	NONE,
	ALL,
	BASENAME
}

var mouse_helper: MouseHelper

#var popup:Popup
var line_edit:LineEdit

static func on_control(control:Control, auto_hide:=true) -> Dialogs.Handlers.LineSubmit:
	var rect = Rect2(Vector2.ZERO, control.size)
	rect.position += UWindow.get_control_absolute_position(control)
	var new = new(control, rect, auto_hide)
	return new

func _init(sel_node, rect:Rect2=Rect2(), auto_hide:=true) -> void:
	_set_root_node(sel_node)
	if rect == Rect2():
		var line_pos = Vector2(DisplayServer.mouse_get_position())
		var local_offset = Vector2(-50, -10)
		line_pos = line_pos + local_offset
		rect = Rect2(line_pos, Vector2(200, 25))
	
	dialog = Popup.new()
	if auto_hide:
		mouse_helper = MouseHelper.new(dialog, _on_timer_elapsed)
	
	line_edit = LineEdit.new()
	line_edit.custom_minimum_size = rect.size
	line_edit.mouse_filter = Control.MOUSE_FILTER_PASS
	
	root_node.add_child(dialog)
	dialog.position = rect.position
	dialog.add_child(line_edit)
	line_edit.grab_focus()
	
	dialog.reset_size()
	dialog.popup()
	dialog.popup_hide.connect(_popup_hide)
	
	line_edit.text_submitted.connect(_on_text_submitted)

func set_text(new_text:String, select:=SelectMode.NONE):
	line_edit.text = new_text
	if select == SelectMode.ALL:
		line_edit.select_all()
	elif select == SelectMode.BASENAME:
		var base_name = new_text.get_basename()
		line_edit.select(0, base_name.length())

func _popup_hide():
	_emit_cancel()

func _on_text_submitted(new_text):
	_emit_handled(new_text)

func _on_timer_elapsed():
	_emit_handled.call_deferred("")


static func make_margin_container(_margin_size:int):
	var _margin := MarginContainer.new()
	var margin_size = _margin_size
	for margin_or in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		_margin.add_theme_constant_override(margin_or, margin_size)
	_margin.mouse_filter = Control.MOUSE_FILTER_STOP
	
	return _margin
