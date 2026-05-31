extends Node2D
# 1. Referência para o Label do Placar
# Altere o caminho para o Label que você criou na cena Game Over
@onready var score_label: Label = $Score

# 2. Referência para o Label do Nome do Jogador
# Altere o caminho para o Label que você criou na cena Game Over
@onready var jogador_label: Label = $jogador

# Usamos _ready() porque essas informações só precisam ser carregadas uma vez
# quando a tela de Game Over é exibida.
func _ready() -> void:
	# 1. EXIBE O SCORE FINAL
	if score_label and is_instance_valid(global):
		# O score já deve ter sido acumulado e salvo no global.score durante a Fase
		score_label.text = "Score: " + str(global.score)
		
	# 2. EXIBE O NOME DO JOGADOR
	if jogador_label and is_instance_valid(global):
		# O nome do jogador já deve ter sido salvo no global.nome_jogador na Tela Início
		jogador_label.text = "Jogador: " + str(global.nome_jogador)

func _on_button_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tela_inicio.tscn")




func _on_button_tentar_novamente_pressed() -> void:
	global.reiniciar()
	get_tree().change_scene_to_file("res://scenes/fase_01.tscn")
	
