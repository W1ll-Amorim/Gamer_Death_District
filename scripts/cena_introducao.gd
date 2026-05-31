extends Node2D # Você pode usar Control, Node3D, ou o nó raiz da sua cena

# 📌 Altere este caminho para o local exato da sua nova fase.
const CAMINHO_DA_PROXIMA_CENA: String = "res://scenes/fase_01.tscn"

# O Godot chama esta função a cada frame.
func _process(_delta: float) -> void:
	# Verifica se a ação "ui_accept" (que é o ENTER por padrão)
	# foi pressionada *neste exato frame*.
	if Input.is_action_just_pressed("ui_accept"):
		mudar_para_a_nova_fase()

# Função dedicada para a transição de cena.
func mudar_para_a_nova_fase() -> void:
	# A função change_scene_to_file() faz a troca de cena.
	var erro: Error = get_tree().change_scene_to_file(CAMINHO_DA_PROXIMA_CENA)
	
	# Verificação de erro para facilitar a depuração (debug)
	if erro != OK:
		print("--- ERRO NA TRANSIÇÃO DE CENA ---")
		print("Código de Erro: ", erro)
		print("Verifique se o arquivo '", CAMINHO_DA_PROXIMA_CENA, "' existe no projeto.")
	else:
		print("Cena carregada com sucesso!")

# Se quiser garantir que a tecla não seja processada por outros elementos (como LineEdit),
# você pode usar a função _unhandled_input.
# No entanto, para um menu simples, _process geralmente é suficiente.
