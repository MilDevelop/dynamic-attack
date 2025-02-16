extends Node2D

@onready var heatlhs_bar = $"Game/HealthsBar"
@onready var HP_Value = $"Game/HealthsBar/HP-Value"
@onready var control = $Control
@onready var player = $Player
@onready var LeaveButton = $Game/LeaveButton
@onready var Background = $Game/ParallaxBackground

var Num_Plr : int = 0

func _ready() -> void:
	Signals.transfer.connect(_spawn)
	Signals.player_number.emit(Num_Plr) ### ???
	heatlhs_bar.max_value = 100
	heatlhs_bar.value = 78

func _process(delta: float) -> void:
	pass

func _on_player_health_changed(new_health: int) -> void:
	heatlhs_bar.value = int((new_health * 78) / 100)
	HP_Value.text = str(new_health)
	
func _spawn(gamer, connection_players):
	call_deferred("add_child", gamer)
	Num_Plr = connection_players

func _on_leave_button_pressed() -> void:
	print("in the following versions")
	#var peer_id = get_multiplayer_authority()
	#multiplayer.connect("peer_disconnected" ,Callable(self, "control._remove_player"), peer_id) 
	#hide()
	#Background.hide()
	#for iter in control.get_children():
		#iter.visible = true
