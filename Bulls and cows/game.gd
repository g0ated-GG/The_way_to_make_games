extends VBoxContainer

enum {BULLS, COWS}

var step = 0
var secret = [0, 0, 0, 0]
var game_end = false

func new_game():
	step = 0
	var numbers = range(10)
	for i in range(secret.size()):
		secret[i] = numbers.pick_random()
		numbers.erase(secret[i])
		get_node("HBoxContainer/NumberLabel%d"%(i+1)).text = ""
	$HistoryLabel.clear()
	game_end = false

# Calculate bulls and cows.
func check(user_input : String):
	var bulls = 0
	var cows = 0
	for i in range(user_input.length()):
		var current = int(user_input[i])
		if current == secret[i]:
			bulls += 1
		elif current in secret:
			cows += 1
	return {BULLS: bulls, COWS: cows}

func print_history(user_input : String, bulls : int, cows : int):
	step += 1
	$HistoryLabel.append_text("[center]%d. %s 🐂%d🐄%d[/center]\n" % [step, user_input, bulls, cows])

# Print the secret value at the end of game.
func print_secret():
	for i in range(secret.size()):
		get_node("HBoxContainer/NumberLabel%d"%(i+1)).text = str(secret[i])

# The main game method that is used after user input has been submitted.
func game(user_input : String):
	if game_end or not $UserInput.is_valid:
		return
	var result = check(user_input)
	print_history(user_input, result[BULLS], result[COWS])
	if (result[BULLS] == secret.size()):
		game_end = true
		print_secret()

func _ready():
	randomize()
	$NewGameButton.pressed.connect(new_game)
	$UserInput.text_submitted.connect(game)
	$UserInput.grab_focus()
	new_game()

func _process(_delta):
	if Input.is_action_just_pressed("new_game"):
		new_game()
