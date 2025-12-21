extends Sprite2D

@export var speed:float = 400
@export var damage:float = 25

func _physics_process(delta: float) -> void:
	global_position += Vector2(speed * delta, 0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
