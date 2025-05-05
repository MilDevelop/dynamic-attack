extends CharacterBody2D

signal health_changed(new_health)
signal new_winner(winner)

enum {
	IDLE,
	MOVE,
	GET_DAMAGE,
	FALL,
	ATTACK_ON_FLOOR,
	FALL_ATTACK
}

enum {
	Up_damage = 10,
	Down_damage = 14,
	Around_damage = 20,
	Slide_damage = 5,
	Base_Fall_damage = 5
}

var Spawn_Host = [Vector2(275, 375), Vector2(105, 150), Vector2(350, 75)]
var Spawn_Guest = [Vector2(875, 375), Vector2(1025, 150), Vector2(800, 75)]

### variables
### MOVE
var SPEED = 300.0
var SLIDE_SPEED = 1.0
const JUMP_VELOCITY = -600.0
var impuls = false
var slide = false

### ANIMATION
@onready var anim = $AnimatedSprite2D
@onready var AnimPlayer = $AnimationPlayer
@onready var NickName = $PlayerLabel
@onready var Light = $PointLight2D
@onready var HB  = $Game/HealthsBar
@onready var Hit_UP =  $"AttackDirectionUP/HitBoxUP/HIt-up"
@onready var Hit_Down = $"AttackDirectionDOWN/hitBoxDOWN/Hit-Down"
@onready var Hit_Slide = $"AttackDirectionSLIDE/hitBoxSLIDE/Hit-Slide"
@onready var Hit_Fall = $"AttackDirectionFALL/HitBoxFALL/Hit-Fall"
var state = IDLE

### ATTACK
var max_hp = 100
var health = 100
var attack_type = true #Attack up
var slide_cooldawn = 100
var Attack_key = false
var Attack_cooldown = false
var Hitten = false
var High = []

### SERVER PARAMETERS
var Host_Player = false
var Player_Name = ""
var damage_current = 0
var given_velocity = Vector2(0, 0)
var deaths : int = 0
var enemy_position_x : int
var Winner : bool

### LIGHT

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func _ready() -> void:
	Player_Name = name
	Host_Player = get_root(Player_Name)
	if Host_Player:
		NickName.text = "HOST"
		position = Spawn_Host[0]
	else:
		NickName.text = "GUEST"
		position = Spawn_Guest[0]
		anim.flip_h = true
	health = max_hp
	Hit_UP.disabled = true
	Hit_Down.disabled = true
	Hit_Slide.disabled = true
	Hit_Fall.disabled = true
	
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		health_changed.connect(get_parent()._on_player_health_changed)
		new_winner.connect(get_parent()._on_new_winner)

func _process(delta: float) -> void:
	Signals.time.connect(_on_time_changed)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if position.y > 650:
			rpc("death_and_reboot")
		var direction := Input.get_axis("ui_left", "ui_right")
		### BASEMENT STATE MACHINE
		match state: 
			MOVE:
				move_state(direction)
			IDLE:
				idle()
			GET_DAMAGE:
				get_damage_state()
			ATTACK_ON_FLOOR:
				Attack_on_floor_State()
			FALL_ATTACK:
				fall_attack_state()
		
		### ACTION CONDITIONS
		if direction:
			state = MOVE
		if is_on_floor():
			if Input.is_action_just_pressed("Attack-Up"):
				attack_type = true
				if !Attack_cooldown:
					state = ATTACK_ON_FLOOR 				
			if Input.is_action_just_pressed("Attack Down"):
				attack_type = false
				if !Attack_cooldown:
					state = ATTACK_ON_FLOOR
			if velocity.x != 0 and is_on_floor() and Hitten and !direction:
				if velocity.x > 0:
					velocity.x -= 5
				if velocity.x < 0:
					velocity.x += 5
			else:
				if Hitten:
					velocity = Vector2.ZERO
					Hitten = false
				impuls = false
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		if !Attack_key:
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				impuls = true
				jump() 
			if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and impuls == true:
				jump()
				impuls = false
			
	if velocity.y > 0:
		if Input.is_action_pressed("ui_down"):
			if High.size() < 1:
				High.append(position.y)
			velocity += round(get_gravity() * delta * 1.3)
			AnimPlayer.play("Fall Attack")
			state = FALL_ATTACK
		else:
			AnimPlayer.play("Fall")
			
	move_and_slide()

func jump():
	velocity.y = JUMP_VELOCITY
	AnimPlayer.play("Jump")
	await anim.animation_finished

func idle():
	Attack_key = false
	Hit_Fall.disabled = true
	High = []
	if !Hitten:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.y == 0:
		AnimPlayer.play("IDEL")
		

func move_state(direction):
	if direction and !Attack_key:
		if multiplayer.get_unique_id() == get_multiplayer_authority():
			disable_attack()
		if slide == true:
			SLIDE_SPEED -= 0.02
		velocity.x = direction * SPEED * SLIDE_SPEED
		if velocity.y == 0:
			if !slide:
				AnimPlayer.play("Run")
				slide_cooldawn += 1
			if slide and velocity.x != 0:
				slide_cooldawn = 0
				damage_current = Slide_damage
				if Hit_Slide.position.x > 0:
					given_velocity = Vector2(100, -400)
				else:
					given_velocity = Vector2(-100, -400)
				AnimPlayer.play("Slide")
				await AnimPlayer.animation_finished
				slide = false
		else:
			SLIDE_SPEED = 1
	else:
		state = IDLE
		Hit_Slide.disabled = true
	if direction == -1:
		anim.flip_h = true
		Hit_UP.position.x = -39
		Hit_Down.position.x = -39
		Hit_Slide.position.x = -23
		Hit_Fall.position.x = -7.5
	elif direction == 1:
		anim.flip_h = false
		Hit_UP.position.x = 39
		Hit_Down.position.x = 39
		Hit_Slide.position.x = 23
		Hit_Fall.position.x = 7.5
	if Input.is_action_pressed("sit") and direction and slide_cooldawn >= 100 and is_on_floor():
		SLIDE_SPEED = 2.0
		slide = true
	else:
		SLIDE_SPEED = 1.0
		slide = false
		Hit_Slide.disabled = true

func Attack_on_floor_State():
	Attack_key = true
	velocity.x = move_toward(velocity.x, 0, SPEED)
	if attack_type:
		damage_current = Up_damage
		if Hit_UP.position.x > 0:
			given_velocity = Vector2(235, -280)
		else:
			given_velocity = Vector2(-235, -280)
		AnimPlayer.play("Attack Up")
	else:
		damage_current = Down_damage
		if Hit_Down.position.x > 0:
			given_velocity = Vector2(190, 0)
		else:
			given_velocity = Vector2(-190, 0)
		AnimPlayer.play("Attack down")
	await AnimPlayer.animation_finished
	Attack_key = false
	attack_freeze()
	state = IDLE
	
func disable_attack():
	Hit_UP.disabled = true
	Hit_Down.disabled = true
	Hit_Fall.disabled = true
	
func fall_attack_state():
	if velocity.y == 0 and Input.is_action_pressed("ui_down"):
		High.append(position.y)
		Attack_key = true
		velocity.x = 0
		damage_current = define_hign_damage(High)
		given_velocity = Vector2(175, -400)
		AnimPlayer.play("fallen for attack")
		await AnimPlayer.animation_finished
		state = IDLE
	else:
		state = IDLE


func attack_freeze():
	Attack_cooldown = true
	await get_tree().create_timer(0.5)
	Attack_cooldown = false

func get_damage_state():
	Hitten = true
	Hit_Slide.disabled = true
	if AnimPlayer.current_animation != "Hit":
		AnimPlayer.play("Hit")
	state = MOVE


@rpc("call_local", "reliable", "any_peer")
func get_damage(get_damage_current, got_velocity):
	state = GET_DAMAGE
	if slide and velocity.x != 0:
		get_damage_current /= 2
	else:
		health -= get_damage_current
		if got_velocity[0] > 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		set_velocity(got_velocity)
	emit_signal("health_changed", health)
	if health <= 0:
		death_and_reboot.rpc()

@rpc("any_peer", "call_local")
func death_and_reboot():
	AnimPlayer.play("death")
	health = 0
	deaths += 1
	if deaths < 3:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		if Host_Player:
			position = Spawn_Host[rng.randi_range(0, 2)]
			Winner = false
		else:
			position = Spawn_Guest[rng.randi_range(0, 2)]
			Winner = true
		velocity = Vector2.ZERO
		health = max_hp
		emit_signal("health_changed", health)
		emit_signal("new_winner", Winner)
	else:
		deaths = 0
		health = 0
		emit_signal("health_changed", health)
		emit_signal("new_winner", Winner)
		queue_free()
	
	

func define_hign_damage(high):
	return round((abs(high[1] - high[0])) / 100) * Base_Fall_damage
	
func define_hign_velocity(high):
	return round((abs(high[1] - high[0])) / 100) * Base_Fall_damage

func get_root(Player_name):
	if Player_name == "1":
		return true
	return false

func damaging(area: Area2D): 
	var player = area.get_parent().get_parent()
	if player.name != name and is_multiplayer_authority():
		if area.get_parent().get_parent().position.x < position.x and state == FALL_ATTACK:
			given_velocity[0] = -given_velocity[0]
		area.get_parent().get_parent().get_damage.rpc(damage_current, given_velocity)
	return


func _on_hit_box_up_area_entered(area: Area2D) -> void:
	damaging(area)
	
func _on_hit_box_down_area_entered(area: Area2D) -> void:
	damaging(area)
	
func _on_hit_box_slide_area_entered(area: Area2D) -> void:
	damaging(area)

func _on_hit_box_fall_area_entered(area: Area2D) -> void:
	damaging(area)

func _on_time_changed(light_time):
	Light.energy = light_time
