extends Node

onready var backgroundSound = [$BackgroundSound, $BackgroundSound2]
var isCollected = false

func _ready():
	get_tree().paused = true

func _input(event):
	if event.is_action_pressed("ui_accept") and $CanvasLayer/InitialPopup.visible:
		$CanvasLayer/InitialPopup.visible = false
		get_tree().paused = false
		play_random_sound()
	elif event.is_action_pressed("ui_accept") and $CanvasLayer/EndingPopup.visible:
		get_tree().change_scene("res://Scenes/Level1.tscn")
		$CanvasLayer/EndingPopup.visible = false
		$CanvasLayer/EndingPopup/Twitter.disabled = true
		$CanvasLayer/EndingPopup/Twitch.disabled = true
		$CanvasLayer/EndingPopup/Itch.disabled = true
	elif event.is_action_pressed("ui_accept") and $CanvasLayer/DeathPopup.visible:
		get_tree().reload_current_scene()
		$CanvasLayer/DeathPopup.visible = false

func ending():
	$CanvasLayer/EndingPopup/Twitter.disabled = false
	$CanvasLayer/EndingPopup/Twitch.disabled = false
	$CanvasLayer/EndingPopup/Itch.disabled = false
	$CanvasLayer/EndingPopup.visible = true

func dead():
	$CanvasLayer/DeathPopup.visible = true

func _on_Twitter_pressed():
	OS.shell_open("https://twitter.com/FelipeRattu")

func _on_Twitch_pressed():
	OS.shell_open("https://www.twitch.tv/feliperattu")

func _on_Itch_pressed():
	OS.shell_open("https://feliperattu.itch.io/")

func play_random_sound():
	randomize()
	var ran = round(rand_range(0, 1))
	backgroundSound[ran].play()


func _on_BackgroundSound_finished():
	play_random_sound()
