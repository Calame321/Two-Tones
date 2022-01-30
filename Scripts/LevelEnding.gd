extends Area2D

export (PackedScene) var nextLevel
onready var animationPlayer = $AnimationPlayer
export (bool) var isGameEnding = false


func _on_LevelEnding_body_entered(body):
	if body.is_in_group("Player"):
		if body.isGrounded:
			if !isGameEnding:
				animationPlayer.play("open")
				yield(animationPlayer, "animation_finished")
				next_level()
			else:
				animationPlayer.play("open")
				yield(animationPlayer, "animation_finished")
				body.ending()

func next_level():
	get_tree().change_scene_to(nextLevel)
