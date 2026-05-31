extends Area2D


#" Configurações do Movimento
const VELOCIDADE_MOVIMENTO = 6.0 # Velocidade em pixels por segundo
const LIMITE_MOVIMENTO = 3.0     # Distância total que o objeto irá se mover (3 pixels)

# Variáveis internas
var y_inicial: float
var direcao_y = 1.0 # 1 para baixo, -1 para cima

func _ready():
	# 1. Armazena a posição Y onde o item começou (ponto central)
	y_inicial = position.y

func _process(delta):
	# O _process é chamado a cada frame e é ideal para mover nós não-físicos.
	
	# 2. Aplica o movimento na posição Y
	position.y += direcao_y * VELOCIDADE_MOVIMENTO * delta
	
	# 3. Lógica de Inversão de Direção
	
	# Se atingiu o limite INFERIOR (LIMITE_MOVIMENTO pixels ABAIXO do ponto inicial)
	if position.y >= y_inicial + LIMITE_MOVIMENTO:
		direcao_y = -1.0 # Inverte para CIMA
	
	# Se atingiu o limite SUPERIOR (LIMITE_MOVIMENTO pixels ACIMA do ponto inicial)
	elif position.y <= y_inicial - LIMITE_MOVIMENTO:
		direcao_y = 1.0 # Inverte para BAIXO


# ====================================================
# FUNÇÃO DE COLETA (CHAMADA PELO SINAL body_entered)
# ====================================================
func _on_body_entered(body: Node2D) -> void:
	ganhar_vida(body)

# ====================================================
# LÓGICA DE AUMENTO DE VIDA
# ====================================================
func ganhar_vida(body: Node2D) -> void:
	# Verifica se o nó que entrou é o Player
	if body.is_in_group("player"):
		# Garante que a vida não ultrapasse 100
		if (global.vida_player < 100):
			global.vida_player += 30
			# Garante que não ultrapasse 100 mesmo após o incremento
			if global.vida_player > 100:
				global.vida_player = 100
			
			# Remove a caixa de vida da cena após ser coletada
			queue_free()
