extends Area2D

signal hit

@export var speed = 400
var screen_size
@export var has_projectiles: bool = false
@export var parent_for_projectiles:NodePath
@export var projectile_scene:PackedScene = preload("res://projectile.tscn")
var alive: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	start(Vector2.ZERO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not alive:
		return
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		
	if has_projectiles:
		if Input.is_action_just_pressed("fire_projectile"):
			fire_projectile()


func _on_body_entered(body: Node2D) -> void:
	hide() # Player disappears after being hit.
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	alive = false
	
func start(pos):
	position = pos
	alive = true
	show()
	$CollisionShape2D.disabled = false
	
func set_level(level_num):
	has_projectiles = true
	
func fire_projectile():
	if not alive:
		return
	print("player: firing projectile")
	print("player: projectile_scene=", projectile_scene)
	var new_projectile = projectile_scene.instantiate()
	new_projectile.global_position = global_position
	var parent = null
	if parent_for_projectiles and str(parent_for_projectiles) != "":
		parent = get_node_or_null(parent_for_projectiles)
	if parent == null:
		parent = get_tree().get_current_scene()
	if parent:
		parent.add_child(new_projectile)
	else:
		push_error("No valid parent found for projectiles")
	print("player: added projectile to parent=", parent)
	print("player: schene file path=", parent.scene_file_path)
	print("player: name=", parent.name)

	#new_projectile.global_position = global_position
	#var parent = get_node(parent_for_projectiles)
	#parent.add_child(new_projectile)
