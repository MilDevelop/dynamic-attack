extends Node2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

enum {
	SUNNY,
	SNOW,
	STORM
}

@onready var light = $Light/DirectionalLight2D
@onready var Lighters = $Light/PointLighters/AnimatedWorldSptites
@onready var Pointers = $Light/PointLighters
@onready var Snow : GPUParticles2D = $Weather/Snow
@onready var ParticlesOfSnow : ParticleProcessMaterial = $Weather/Snow.process_material

var state = MORNING
var weather_state : int

func _ready() -> void:
	if Signals.Number_of_Players == 1 and multiplayer.get_unique_id() != 1:
		pass
	else:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		weather_state = rng.randi_range(0, 2)


func _process(delta: float) -> void:
	Signals.TimesOfDay = state
	for nodes in Lighters.get_children():
		nodes.play("default")
	
	match state:
		MORNING:
			morning_state.rpc()
		EVENING:
			evening_state.rpc()
			
	#match weather_state:
		#SUNNY:
			#sunny_state.rpc()
		#SNOW:
			#snow_state.rpc()
		#STORM:
			#storm_state.rpc()

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
			
#@rpc("any_peer", "call_local", "reliable")
#func sunny_state():
	#Snow.amount = 1
	#Snow.emitting = false
#
#@rpc("any_peer", "call_local", "reliable")
#func snow_state():
	#Snow.emitting = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(Snow, "amount", 30, 7.5)
	#tween.tween_property(ParticlesOfSnow, "initial_velocity_min", 0.0, 7.5)
	#tween.tween_property(ParticlesOfSnow, "initial_velocity_max", 0.0, 7.5)
	#
#@rpc("any_peer", "call_local", "reliable")
#func storm_state():
	#Snow.emitting = true
	#var tween = get_tree().create_tween()
	#tween.tween_property(Snow, "amount", 80, 7.5)
	#tween.tween_property(ParticlesOfSnow, "initial_velocity_min", 15.0, 7.5)
	#tween.tween_property(ParticlesOfSnow, "initial_velocity_max", 40.0, 7.5)

func _on_day_night_timeout() -> void:
	if state == 3:
		state = 0
	else: 
		state += 1
		
func _on_change_weather_timeout() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	weather_state = rng.randi_range(0, 2)
