extends Node

@export var mob_scene: PackedScene
@export var level_up_1: int = 30
@export var lives: int = 3
var score: int = 0
@onready var player: Area2D = $Player
var enemies_killed: int = 0
var highest_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_highest_score() -> void:
	if enemies_killed > highest_score:
		highest_score = enemies_killed

func die() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over(false)
	set_highest_score()
	$Music.stop()
	$DeathSound.play()


func game_over() -> void:
	die()
	$HUD.show_game_over(true)
	$HighestScore.text = "Highest Score " + str(highest_score)
	enemies_killed = 0
	lives = 3
	
	

func new_game():
	score = 0
	enemies_killed = 0
	$HighestScore.text = ""
	$Lives.text = str(lives)
	$EnemyKillCount.text = str(enemies_killed)
	
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Music.play()


# Mob died signal
func _on_enemy_died() -> void:
	enemies_killed += 1
	$EnemyKillCount.text = str(enemies_killed)

func _on_mob_timer_timeout() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	mob.died.connect(_on_enemy_died)
	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's position to the random location.
	mob.position = mob_spawn_location.position

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)
	
	if score >= level_up_1:
		print("main: level up 1")
		player.set_level(1)
		


func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()


func _on_player_hit() -> void:
	die()
	lives -= 1
	$Lives.text = str(lives)
	if lives <= 0:
		game_over()
