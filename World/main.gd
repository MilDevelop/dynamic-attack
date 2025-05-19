extends Node2D

@onready var heatlhs_bar = $Game/GUI/HealthsBar
@onready var HP_Value = $"Game/GUI/HealthsBar/HP-Value"
@onready var control = $Control
@onready var player = $Player #???
@onready var Background = $Game/ParallaxBackground
@onready var temp_mn = $Game/GUI/TemporaryMenu
@onready var New_Game_Button = $"Game/GUI/TemporaryMenu/Panel/VBoxContainer/New Game"
@onready var counterHost = $Game/GUI/Counters/CounterHost
@onready var counterGuest = $Game/GUI/Counters/CounterGuest

var Temporary_Menu : bool = false
var Wins : Array

func _ready() -> void:
	Signals.transfer.connect(_spawn)
	heatlhs_bar.max_value = 100
	heatlhs_bar.value = 78
	Wins = [0, 0]
	
func _process(delta: float) -> void:
	counterHost.frame = Wins[0]
	counterGuest.frame = Wins[1]
	Signals._conditional()
	if Input.is_action_just_pressed("ui_cancel"):
		Temporary_Menu = !Temporary_Menu

	if Temporary_Menu:
		temp_mn.show()
	else:
		temp_mn.hide()
	
	if Signals.Number_of_Players == 1:
		Wins = [0, 0]
		
	if multiplayer.get_unique_id() == 1 and Signals.Number_of_Players > 1: 
		New_Game_Button.disabled = false
	else:
		New_Game_Button.disabled = true

func _on_player_health_changed(new_health: int) -> void:
	heatlhs_bar.value = int((new_health * 78) / 100)
	HP_Value.text = str(new_health)

func zero_value_GUI():
	heatlhs_bar.value = 0

func _spawn(gamer):
	call_deferred("add_child", gamer)

func _on_new_winner(winner_player : bool):
	if winner_player: 
		rpc("win", winner_player)
	else:
		if Signals.Number_of_Players > 1:
			rpc("win", winner_player)
	
@rpc("any_peer", "call_local", "reliable")
func win(winner_player : bool):
	if winner_player == true: #If Host player
		Wins[0] += 1
		return
	Wins[1] += 1
	
func _on_resume_pressed() -> void:
	Temporary_Menu = !Temporary_Menu
	
func _on_new_game_pressed() -> void:
	control.respawn_everyone.rpc()
