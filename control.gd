extends Control

const PORT = 1999

var peer = ENetMultiplayerPeer.new()
var Room : String = "localhost"
var conection_players : int = 0

@export var player_scene : PackedScene
@onready var host_button = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/Host
@onready var UserInput = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/LineEdit
@onready var ctr = $CanvasLayer
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
	peer.create_client(Room, PORT)
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
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player()
	UPnP_setup()
	Paralax.visible = true
	Game.visible = true
	ctr.visible = false
	
func _remove_player(peer_id):
	var format_string = "../{str}"
	var actual_string = format_string.format({"str": str(peer_id)})
	var player = get_node_or_null(actual_string)
	if player:
		
		player.queue_free()

func _on_enter_pressed() -> void:
	if UserInput.text != "":
		host_button.disabled = false
		Room = UserInput.text

func UPnP_setup():
	var UPnP = UPNP.new()
	var discover_result = UPnP.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover failed %s" % discover_result)
	if (UPnP.get_gateway() and UPnP.get_gateway().is_valid_gateway()) == false:
		Room = "192.168.100.1"
		return
	assert(UPnP.get_gateway() and UPnP.get_gateway().is_valid_gateway(), \
	"UPnP invalid gateway")
	var map_result = UPnP.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover failed %s" % map_result)
	print("Successful connection, Join Address: %s" % UPnP.query_external_address())
	
	
	
