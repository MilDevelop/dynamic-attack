extends CharacterBody2D

var health = 200
@onready var player_side = $"AttackDirectionUP/HitBoxUP/HIt-up"

func _ready() -> void:
	queue_free()
	Signals.connect("player_attack", Callable(self, "_damage_received"))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if is_on_floor() and velocity.x != 0:
		if velocity.x < 0:
			velocity.x += 5
		if velocity.x > 0:
			velocity.x -= 5
	
	move_and_slide()

func _damage_received(player_damage, velocity_damage): ###VELOCITY
	health -= player_damage
	get_boost(velocity_damage)
	if health <= 0:
		health = 0
		queue_free()
	print(health)

func get_boost(velocity_damage: Vector2):
	velocity = velocity_damage
