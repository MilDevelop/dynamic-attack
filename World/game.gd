extends Node2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

#enum {
	#SUNNY,
	#SNOW,
	#STORM
#}

@onready var light = $Light/DirectionalLight2D
@onready var Lighters = $Light/PointLighters/AnimatedWorldSptites
@onready var Pointers = $Light/PointLighters
@onready var Snow : GPUParticles2D = $Weather/Snow
@onready var ParticlesOfSnow : ParticleProcessMaterial = $Weather/Snow.process_material

var state : int = MORNING
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	pass
	#if multiplayer.get_unique_id() == 1:
		#rng.randomize()
		#weather_state = rng.randi_range(0, 2)

func _process(delta: float) -> void:
	Signals.time.emit(light.energy)
	Signals.TimesOfDay = state
	for nodes in Lighters.get_children():
		nodes.play("default")
	
	match state:
		MORNING:
			morning_state.rpc()
		EVENING:
			evening_state.rpc()
			
	#change_weather(weather_state)
	

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
			
#@rpc("any_peer" ,"call_local")
#func sunny_state():
	#Snow.amount = 0
	#Snow.emitting = false
#
#@rpc("any_peer" ,"call_local")
#func snow_state():
	#Snow.emitting = true
	#Snow.amount = 30
	#ParticlesOfSnow.initial_velocity_max = 0.0
	#ParticlesOfSnow.initial_velocity_min = 0.0
	##var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	##tween.set_parallel(true)
	##tween.tween_property(Snow, "amount", 30, 7.5)
	##tween.tween_property(ParticlesOfSnow, "initial_velocity_min", 0.0, 7.5)
	##tween.tween_property(ParticlesOfSnow, "initial_velocity_max", 0.0, 7.5)
	#
#@rpc("any_peer" ,"call_local")
#func storm_state():
	#Snow.emitting = true
	#Snow.amount = 110
	#ParticlesOfSnow.initial_velocity_max = 15.0
	#ParticlesOfSnow.initial_velocity_min = 40.0
	##var tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_ELASTIC)
	##tween.set_parallel(true)
	##tween.tween_property(Snow, "amount", 110, 7.5)
	##tween.tween_property(ParticlesOfSnow, "initial_velocity_min", 15.0, 7.5)
	##tween.tween_property(ParticlesOfSnow, "initial_velocity_max", 40.0, 7.5)

func _on_day_night_timeout() -> void:
	if state == 3:
		state = 0
	else: 
		state += 1
		
func _on_change_weather_timeout() -> void:
	pass
	#if multiplayer.get_unique_id() == 1:
		#rng.randomize()
		#weather_state = rng.randi_range(0, 2)
