extends KinematicBody2D

# CACHE RELATED #
onready var sprite = get_node("Sprite")
onready var tween = get_node("Tween")
onready var deathParticles = get_node("DeathParticles")
onready var endingAnimation = get_node("EndingAnimation")

# MOVEMENT RELATED #
var move = Vector2.ZERO
export (Vector2) var normal = Vector2.UP
export (int) var speed = 150
var velocityX
var velocityY
var isGrounded : bool

# JUMP RELATED #
var jumped = false
export (int) var jumpHeight = 105
export (float) var jumpTimeToPeak = .35
export (float) var jumpTimeToDescent = .30
var jumpForce : float = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
var weightUp : float = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
var weightDown : float = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0
var weight : float = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0
export (float) var coyoteTime = 0.1

# INPUT RELATED #
var lastInputOnFloor = 0

# LEVEL RELATED #
onready var level = get_parent()

# STATE RELATED #
var isDead = false
var hasWon = false

func get_floor_value():
	isGrounded = is_on_floor()

func apply_movement():
	move = move_and_slide(move, normal, true)

func check_input_x() -> int:
	var inputX = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return inputX

func check_input_y() -> int:
	if Input.is_action_just_pressed("ui_up") and isGrounded:
		return -1
	elif Input.is_action_just_pressed("ui_down"):
		return 1
	else:
		return 0

func change_color():
	if Input.is_action_just_pressed("change_color") and level.tweenCompleted:
		match level.backgroundColor:
			level.color.BLACK:
				level.change_color(level.color.WHITE)
				tween.interpolate_property(sprite, "modulate", sprite.modulate, Color.black, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.interpolate_property(deathParticles, "color", deathParticles.color, Color.black, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.start()
			level.color.WHITE:
				level.change_color(level.color.BLACK)
				tween.interpolate_property(sprite, "modulate", sprite.modulate, Color.white, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.interpolate_property(deathParticles, "color", deathParticles.color, Color.white, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.start()

func change_color_to(levelColor):
	sprite.modulate = levelColor

func check_general_inputs():
	change_color()
	var ix = check_input_x()
	
	manage_air_horizontal_move(ix)
	
	var iy = check_input_y()
	
	if iy == -1:
		jumped = true
	
	if Input.is_action_just_released("ui_up"):
		weight = weightDown*2

func manage_air_horizontal_move(ix):
	if isGrounded:
		move.x = ix * (speed*1.5)
		lastInputOnFloor = ix
	elif !isGrounded:
		if lastInputOnFloor == 0:
			move.x = ix * speed
			lastInputOnFloor = ix
		else:
			move.x = (lastInputOnFloor * speed) + (ix * int(speed/2))

func apply_gravity(delta):
	move.y += (weight) * delta

func calculate_velocity(delta):
	velocityX = int(move.x / delta)
	velocityY = int(move.y / delta)

func jump():
	weight = weightUp
	move.y += jumpForce

func fall():
	weight = weightDown
	jumped = false

func coyote():
	isGrounded = true
	weight = 0.0
	yield(get_tree().create_timer(coyoteTime), "timeout")
	isGrounded = false

func _on_HazardDetection_body_entered(body):
	if body.is_in_group("Hazard"):
		isDead = true

func _on_HazardDetection_area_entered(area):
	if area.is_in_group("LevelEnding") and isGrounded:
		hasWon = true

func ending():
	endingAnimation.play("ending")
	tween.interpolate_property(sprite, "modulate", sprite.modulate, Color.black, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(deathParticles, "color", deathParticles.color, Color.black, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(endingAnimation, "animation_finished")
	GameManager.ending()
