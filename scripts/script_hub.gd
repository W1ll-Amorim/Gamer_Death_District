
extends CanvasLayer  # ou Node, dependendo da sua cena HUD

  
@onready var score_label: Label = $Control/Score# o Label dentro do HUB

func _process(delta):
	if score_label:
		score_label.text = str(global.score)
