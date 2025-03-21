extends Node2D

@onready var heatlhs_bar = $Game/GUI/HealthsBar
@onready var HP_Value = $"Game/GUI/HealthsBar/HP-Value"
@onready var control = $Control
@onready var player = $Player
@onready var Background = $Game/ParallaxBackground
@onready var temp_mn = $Game/GUI/TemporaryMenu

var Num_Plr : int = 0
var Temporary_Menu : bool = false

func _ready() -> void:
	Signals.transfer.connect(_spawn)
	Signals.player_number.emit(Num_Plr) ### ???
	heatlhs_bar.max_value = 100
	heatlhs_bar.value = 78

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Temporary_Menu = !Temporary_Menu
	
	if Temporary_Menu:
		temp_mn.show()
	else:
		temp_mn.hide()

func _on_player_health_changed(new_health: int) -> void:
	heatlhs_bar.value = int((new_health * 78) / 100)
	HP_Value.text = str(new_health)
	
func _spawn(gamer, connection_players):
	call_deferred("add_child", gamer)
	Num_Plr = connection_players


func _on_resume_pressed() -> void:
	Temporary_Menu = !Temporary_Menu
