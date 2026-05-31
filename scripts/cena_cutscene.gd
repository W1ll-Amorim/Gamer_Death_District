extends Node2D

func _ready():
	# Toca a animação da cutscene
	$AnimationPlayer.play("cutscene")
	
	# Conecta o sinal para trocar de cena quando a animação terminar
	$AnimationPlayer.animation_finished.connect(_on_cutscene_finished)


func _on_cutscene_finished(anim_name):
	if anim_name == "cutscene":
		get_tree().change_scene_to_file("res://scenes/cena_introducao.tscn")
