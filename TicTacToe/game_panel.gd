extends VBoxContainer

const EMPTY = 0
const X = 1
const O = -1

const X_icon = preload("res://X.tres")
const O_icon = preload("res://O.tres")

@export var field_size = Vector2(3, 3)

# Game model.
var field : Array[int] = [ ]

# Clear model and view.
func clear():
	field.fill(EMPTY)
	for y in range(field_size.y):
		for x in range(field_size.x):
			get_node("Game/GameButtons/Button"+str(y*field_size.x + x)).icon = null
	$Game/Overlay.visible = false

func _ready():
	randomize()
	field.resize(field_size.x * field_size.y)
	clear()
	# Buttons connecting.
	for y in range(field_size.y):
		for x in range(field_size.x):
			var button = get_node("Game/GameButtons/Button"+str(y*field_size.x + x))
			button.pressed.connect(step.bind(x, y))

# Mark cell by user or enemy.
func mark(sign : int, x : int, y : int):
	if sign in [X, O, EMPTY] and \
			x >= 0 and x < field_size.x and \
			y >= 0 and y < field_size.y:
		var i = y*field_size.x + x
		field[i] = sign
		var button = get_node("Game/GameButtons/Button"+str(i))
		match sign:
			X:
				button.icon = X_icon
			O:
				button.icon = O_icon
			EMPTY:
				button.icon = null

# Checking selected line.
func check_line(line : Array[int]):
	var sum = 0
	for i in line:
		sum += i
	if sum == len(line):
		return true
	if sum == - len(line):
		return false
	return null

# Checking all lines (horizontal, vertical and diagonal).
func check():
	# Rows.
	for y in range(field_size.y):
		var row = field.slice(y * field_size.x, y * field_size.x + field_size.x)
		var res = check_line(row)
		if res != null:
			return res
	# Columns.
	for x in range(field_size.x):
		var col = field.slice(x, x + (field_size.y-1)*field_size.x + 1, field_size.x)
		var res = check_line(col)
		if res != null:
			return res
	# Diagonal 1 (from top to bottom, from left to right).
	var buffer : Array[int] = [ ]
	for x in range(field_size.x):
		buffer.append(field[x + x*field_size.x])
	var res = check_line(buffer)
	if res != null:
		return res
	# Diagonal 2 (from top to bottom, from right to left).
	buffer.clear()
	for x in range(field_size.x):
		buffer.append(field[(x+1)*field_size.x - x - 1])
	res = check_line(buffer)
	if res != null:
		return res
	# game continues
	return null

# Checking game state. If you win or lose, it makes sense to show the message about it.
func check_game():
	var state = check()
	if state == true:
		OS.alert("YOU WIN!!!", "Game end")
		$Game/Overlay.visible = true
		return false
	elif state == false:
		OS.alert("You lose!", "Game end")
		$Game/Overlay.visible = true
		return false
	return true

# User step. Enemy steps through a delay.
func step(x : int, y : int):
	mark(X, x, y)
	if check_game():
		$Timer.start()

# Enemy step after delay.
func _on_timer_timeout():
	var indexes = [ ]
	for i in range(field.size()):
		if field[i] == EMPTY:
			indexes.append(i)
	var enemy_choice = indexes.pick_random()
	var y = int(enemy_choice / field_size.x)
	var x = enemy_choice - y * field_size.x
	mark(O, x, y)
	check_game()

func _on_new_game_button_pressed():
	clear()
