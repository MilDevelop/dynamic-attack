extends ParallaxBackground

var speed = 70

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	scroll_offset.x -= delta * speed
