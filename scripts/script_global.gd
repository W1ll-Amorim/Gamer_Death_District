extends Node

var vida_player: int = 100
var ultima_posicao = null
var nome_jogador: String = ""
var score: int = 0

func resetar():
	vida_player = 100
	ultima_posicao = null

func iniciar_jogo(nome):
	nome_jogador = nome
	
	
	get_tree().change_scene_to_file("res://scenes/cena_cutscene.tscn")
	
func reiniciar():
	vida_player = 100
	ultima_posicao = null
	score = 0

func pontos():
	score += 150

func remover_inimigos():

	for inimigo in get_tree().get_nodes_in_group("inimigo"):

		if is_instance_valid(inimigo):

			inimigo.queue_free()
