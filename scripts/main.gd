extends Node2D

onready var brick = preload("res://scenes/Brick.tscn")
onready var ball = preload("res://scenes/Ball.tscn")

export(float) var player_speed = 800

var ball_direction = Vector2.ZERO

var max_bricks
var n_bricks = 0

var max_player_health = 3
var player_health = max_player_health

var ball_initial_position = Vector2(360, 440)

var score = 0

# UI:
onready var sc_label = $UI/score_counter
onready var game_over_screen = $UI/game_over_screen
onready var gos_label = $UI/game_over_screen/Label

func _ready():
	set_bricks()
	
	ball_direction = Vector2(250, 250)

func _physics_process(delta):
	# Player:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	velocity.y = 0
	$Player.move_and_slide(velocity * player_speed)
	
	# Ball:
	var collision = $Ball.move_and_collide(ball_direction * delta)
	if collision:
		var reflect = collision.remainder.bounce(collision.normal)
		ball_direction = ball_direction.bounce(collision.normal)
		$Ball.move_and_collide(reflect)
		$Ball/ball_bounce.play()
		
		if collision.collider.is_in_group("Brick"):
			collision.collider.queue_free()
			score += 1
			
			sc_label.text = str(score)

	# Game End:
	if score >= max_bricks || player_health <= 0:
		game_over()

func set_bricks():
	n_bricks = 0
	for i in range(5): # rows
		for j in range(12): # columns
			var br = brick.instance()
			br.position = Vector2(120 + 70 * (j), 70 + 50 * i)
			n_bricks += 1
			max_bricks = n_bricks
			add_child_below_node($Level, br)

func game_over():
	game_over_screen.visible = true
	if score >= max_bricks:
		gos_label.text = "Level cleared! Well done!"
	elif player_health <= 0:
		gos_label.text = "Too bad! Better luck next time!"

func _on_Dead_Zone_body_entered(body):
	player_health -= 1
	body.position = Vector2(ball_initial_position)
	$AnimationPlayer.play("screen_dim")

func _on_play_again_pressed():
	unpause_game()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()

func pause_game():
	get_tree().paused = true

func unpause_game():
	get_tree().paused = false
