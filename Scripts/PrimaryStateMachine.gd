extends StateMachine

onready var animationPlayer = get_parent().get_node("AnimationPlayer")
onready var tweenPlayer = get_parent().get_node("TweenPlayer")
onready var sprite = get_parent().get_node("Sprite")
onready var deathParticles = get_parent().get_node("DeathParticles")
onready var sounds = [
	get_parent().get_node("Jump"),
	get_parent().get_node("Fall"),
	get_parent().get_node("Death")
]

func _ready():
	add_state("IDLE")
	add_state("WALK")
	add_state("JUMP")
	add_state("FALL")
	add_state("COYOTE")
	add_state("DEAD")
	add_state("WIN")
	call_deferred("set_state", states.IDLE)

func _state_logic(delta):
	if state != states.DEAD:
		if state != states.COYOTE:
			parent.get_floor_value()
		if state != states.WIN:
			parent.check_general_inputs()
			parent.apply_movement()
		parent.apply_gravity(delta)
		parent.calculate_velocity(delta)
	

func _get_transition(delta):
	match state:
		states.IDLE:
			if parent.jumped:
				return states.JUMP
			elif parent.move.x != 0:
				return states.WALK
			elif parent.isDead:
				return states.DEAD
			elif parent.hasWon:
				return states.WIN
		states.JUMP:
			if parent.velocityY >= 0:
				return states.FALL
			elif parent.isDead:
				return states.DEAD
		states.WALK:
			if parent.move.x == 0:
				return states.IDLE
			elif parent.jumped:
				return states.JUMP
			elif !parent.isGrounded and parent.velocityY >= 0:
				return states.COYOTE
			elif parent.isDead:
				return states.DEAD
			elif parent.hasWon:
				return states.WIN
		states.FALL:
			if parent.isGrounded and parent.move.x == 0:
				return states.IDLE
			elif parent.isGrounded:
				return states.WALK
			elif parent.isDead:
				return states.DEAD
		states.COYOTE:
			if parent.jumped:
				return states.JUMP
			elif !parent.isGrounded:
				return states.FALL
			elif parent.isDead:
				return states.DEAD
			elif parent.hasWon:
				return states.WIN

func _enter_state(new_state, old_state):
	match new_state:
		states.IDLE:
			animationPlayer.play("idle")
		states.WALK:
			animationPlayer.play("walk")
			change_direction()
		states.JUMP:
			sounds[0].play()
			animationPlayer.play("jump")
			tween_vertical_scale()
			parent.jump()
			change_direction()
		states.FALL:
			parent.fall()
			change_direction()
		states.COYOTE:
			parent.coyote()
			change_direction()
		states.DEAD:
			sounds[2].play()
			animationPlayer.play("dead")
			tweenPlayer.interpolate_property(deathParticles, 'color:a', 1, -1, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
			tweenPlayer.start()
			GameManager.dead()
		states.WIN:
			animationPlayer.play("win")

func _exit_state(old_state, new_state):
	match old_state:
		states.FALL:
			sounds[1].play()
			tween_vertical_scale()

func change_direction():
	if parent.velocityX > 0:
		sprite.scale.x = 1
	elif parent.velocityX < 0:
		sprite.scale.x = -1

func tween_vertical_scale():
	tweenPlayer.interpolate_property(sprite, "scale:y", 1, 0.6, .15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweenPlayer.interpolate_property(sprite, "position:y", 0, 42, .15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweenPlayer.interpolate_property(sprite, "scale:y", .6, 1, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweenPlayer.interpolate_property(sprite, "position:y", 42, 0, 0.15, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tweenPlayer.start()
