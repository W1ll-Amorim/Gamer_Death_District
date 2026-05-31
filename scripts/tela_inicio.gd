extends Node2D

func iniciar_jogo() -> void:
	var nome = $LineEdit.text
	global.iniciar_jogo(nome)
	
