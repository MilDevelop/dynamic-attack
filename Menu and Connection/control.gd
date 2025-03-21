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
@onready var GUI = $"../Game/GUI"
@onready var IP_Ref = $"../Game/GUI/TemporaryMenu/Panel/VBoxContainer/ReferenceToIP"
	
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_join_pressed() -> void:
	peer.create_client(Room, PORT)
	IP_Ref.text += Room
	multiplayer.multiplayer_peer = peer
	multiplayer.server_disconnected.connect(_on_quit_pressed)
	if peer:
		print("Your join on server " + str(PORT))
	hide_items()


func _add_player(id = 1):
	var pr = player_scene.instantiate()
	pr.name = str(id)
	if multiplayer.is_server():
		conection_players += 1
		Signals.emit_signal("transfer", pr, conection_players)
		
		
func _on_host_pressed() -> void:
	peer.create_server(PORT)
	if peer:
		print("Server started on port " + str(PORT))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	_add_player()
	UPnP_setup()
	hide_items()

func _remove_player(peer_id):
	var format_string = "../{str}"
	var actual_string = format_string.format({"str": str(peer_id)})
	var player = get_node_or_null(actual_string)
	if player:
		conection_players -= 1
		player.queue_free()

func _on_enter_pressed() -> void:
	if UserInput.text != "":
		Room = UserInput.text

func _on_quit_pressed() -> void:
	for node in get_tree().get_nodes_in_group("Player"):
		node.queue_free()
	multiplayer.multiplayer_peer.close()
	multiplayer.set_deferred(&"multiplayer_peer", null)
	show_items()

func UPnP_setup():
	var UPnP = UPNP.new()
	var discover_result = UPnP.discover()
	if (UPnP.get_gateway() and UPnP.get_gateway().is_valid_gateway() or discover_result != UPNP.UPNP_RESULT_SUCCESS) == false:
		var ip
		for address in IP.get_local_addresses():
			if (address.split('.')[0] == "192"):
				ip = address
		IP_Ref.text = IP_Ref.text + "%s" % ip
		print("Your local IP-Adress: %s" % ip)
		return
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover failed %s" % discover_result)
	assert(UPnP.get_gateway() and UPnP.get_gateway().is_valid_gateway(), \
	"UPnP invalid gateway")
	var map_result = UPnP.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
	"UPNP Discover failed %s" % map_result)
	IP_Ref.text = IP_Ref.text + "%s" % UPnP.query_external_address()
	print("Successful connection, Join Address: %s" % UPnP.query_external_address())
	
	
func hide_items() -> void:
	$ParallaxBackground.visible = false
	$CanvasLayer.visible = false
	Paralax.visible = true
	Game.visible = true
	GUI.visible = true
	
	
func show_items() -> void:
	IP_Ref.text = ""
	$ParallaxBackground.visible = true
	$CanvasLayer.visible = true
	Paralax.visible = false
	Game.visible = false
	GUI.visible = false
	
