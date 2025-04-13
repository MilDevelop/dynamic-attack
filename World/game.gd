extends Node2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

@onready var light = $Light/DirectionalLight2D
@onready var Lighters = $Light/PointLighters/AnimatedWorldSptites
@onready var Pointers = $Light/PointLighters
@onready var Snow = $Snow

var state = MORNING

func _process(delta: float) -> void:
	
	
	Signals.TimesOfDay = state
	for nodes in Lighters.get_children():
		nodes.play("default")
	
	match state:
		MORNING:
			morning_state.rpc()
		EVENING:
			evening_state.rpc()

@rpc("any_peer" ,"call_local", "reliable")
func morning_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.0, 30)
	dynamic_light(false)
	
@rpc("any_peer", "call_local", "reliable")
func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.85, 30)
	dynamic_light(true)

func dynamic_light(light : bool):
	var point = 1.0
	if !light:
		point = 0.0
	for node in Pointers.get_children():
		var tween_substrack = get_tree().create_tween()
		if node.name != "AnimatedWorldSptites":
			tween_substrack.tween_property(node, "energy", point, 30)

func _on_day_night_timeout() -> void:
	if state == 3:
		state = 0
	else: 
		state += 1
		
