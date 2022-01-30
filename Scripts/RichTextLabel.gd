extends RichTextLabel

func _process(delta):
	if !get_tree().paused:
		self.visible = true
		set_process(false)
