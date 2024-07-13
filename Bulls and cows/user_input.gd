extends LineEdit

const NORMAL_COLOR = Color.WHITE
const ERROR_COLOR = Color.RED

var four_digits = RegEx.new()
var digit = RegEx.new()
var old_value = ""
@export var is_valid = true

# Controlling the input by whole text (in the case of paste or replace).
func input_control(new_text : String):
	if four_digits.search(new_text):
		old_value = str(new_text)
	else:
		text = old_value
		caret_column = text.length()
	is_valid = all_unique(text)

# Controlling the input by symbol.
func digit_changed(digit_str : String):
	if digit.search(digit_str):
		var old_pos = clampi(caret_column, 0, 3)
		text[old_pos] = digit_str
		old_value = text
		var pos = clampi(old_pos + 1, 0, 3)
		if (old_pos == pos):
			pos = 0
		caret_column = pos
		is_valid = all_unique(text)

# All symbols are unique.
func all_unique(value : String):
	for c in value:
		if value.count(c) > 1:
			add_theme_color_override("font_color", ERROR_COLOR)
			return false
	add_theme_color_override("font_color", NORMAL_COLOR)
	return true

func _ready():
	four_digits.compile("^\\d{4}$")
	digit.compile("^\\d$")
	old_value = text
	text_changed.connect(input_control)
	text_change_rejected.connect(digit_changed)
	focus_exited.connect(grab_focus)
