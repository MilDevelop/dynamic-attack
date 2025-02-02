extends Control

const PORT = 1999

var peer = ENetMultiplayerPeer.new()
var RoomName : String = ""
var conection_players : int = 0

@export var player_scene : PackedScene
@onready var host_button = $Host
@onready var UserInput = $LineEdit
@onready var ctr = $"."
@onready var Game = $"../Game"
@onready var Paralax = $"../Game/ParallaxBackground"
	
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	pass

func _on_join_pressed() -> void:
	peer.create_client("127.0.0.1", PORT)
	multiplayer.multiplayer_peer = peer
	for iter in ctr.get_children():
		iter.hide()
	if peer:
		print("Your join on server " + str(PORT))
	Paralax.visible = true
	Game.visible = true
	ctr.visible = false

	
func _add_player(id = 1):
	var pr = player_scene.instantiate()
	pr.name = str(id)
	if multiplayer.is_server():
		conection_players += 1
		Signals.emit_signal("transfer", pr, conection_players)

func _on_host_pressed() -> void:
	peer.create_server(PORT, 2)
	if peer:
		print("Server started on port " + str(PORT))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	Paralax.visible = true
	Game.visible = true
	ctr.visible = false


func _on_enter_pressed() -> void:
	if UserInput.text != "":
		host_button.disabled = false
		RoomName = UserInput.text
		
