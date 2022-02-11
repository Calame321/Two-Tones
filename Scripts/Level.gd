extends Node2D

enum color {BLACK, WHITE, GRAY}
export (color) var backgroundColor

onready var black = get_node("BlackTileMap")
onready var white = get_node("WhiteTileMap")
onready var tween = get_node("Tween")
onready var player = get_node("Player")
onready var woom = get_node("WOOOM")

var tweenCompleted = true

func _ready():
	$Camera2D/ColorRect.visible = true
	check_background_color()
	match backgroundColor:
		color.BLACK:
			player.change_color_to(Color.white)
		color.WHITE:
			player.change_color_to(Color.black)

func change_color(hue, isFistSwitch = false):
	backgroundColor = hue
	if tweenCompleted:
		match backgroundColor:
			color.BLACK:
				tweenCompleted = false
				tween.interpolate_property($Camera2D/ColorRect,
				'color', $Camera2D/ColorRect.color,
				Color.black, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.interpolate_property(woom,
				'pitch_scale', woom.pitch_scale,
				0.8, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
				if isFistSwitch:
					isFistSwitch = false
				else:
					woom.play()
				tween.start()
				white.set_collision_layer_bit(0, true)
				white.set_collision_mask_bit(0, true)
				yield(tween, "tween_all_completed")
				black.set_collision_layer_bit(0, false)
				black.set_collision_mask_bit(0, false)
				tweenCompleted = true
			color.WHITE:
				tweenCompleted = false
				tween.interpolate_property($Camera2D/ColorRect, 
				'color', $Camera2D/ColorRect.color, 
				Color.white, 1, 
				Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.interpolate_property(woom,
				'pitch_scale', woom.pitch_scale,
				1, 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
				if isFistSwitch:
					isFistSwitch = false
				else:
					woom.play()
				tween.start()
				black.set_collision_layer_bit(0, true)
				black.set_collision_mask_bit(0, true)
				yield(tween, "tween_all_completed")
				white.set_collision_layer_bit(0, false)
				white.set_collision_mask_bit(0, false)
				tweenCompleted = true
			color.GRAY:
				tweenCompleted = false
				tween.interpolate_property($Camera2D/ColorRect, 
				'color', $Camera2D/ColorRect.color, 
				Color('#767676'), .5, 
				Tween.TRANS_LINEAR, Tween.EASE_IN)
				tween.start()
				yield(tween, "tween_all_completed")
				white.set_collision_layer_bit(0, true)
				white.set_collision_mask_bit(0, true)
				black.set_collision_layer_bit(0, true)
				black.set_collision_mask_bit(0, true)
				tweenCompleted = true

func check_background_color():
	match backgroundColor:
		color.WHITE:
			black.set_collision_layer_bit(0, true)
			black.set_collision_mask_bit(0, true)
			white.set_collision_layer_bit(0, false)
			white.set_collision_mask_bit(0, false)
		color.BLACK:
			white.set_collision_layer_bit(0, true)
			white.set_collision_mask_bit(0, true)
			black.set_collision_layer_bit(0, false)
			black.set_collision_mask_bit(0, false)
			
