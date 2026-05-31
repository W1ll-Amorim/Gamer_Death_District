extends CharacterBody2D

var damage_info: PackedScene = preload("res://scenes/cena_damage_label.tscn")
@onready var damage_position: Marker2D = $damage_position

# ====================================
# 1. VARIÁVEIS ESTÁTICAS PARA O DROP
# ====================================
static var kills_since_last_drop: int = 0
static var drop_threshold: int = 0
static var is_initialized: bool = false
# ====================================

# === CONFIGURAÇÕES DE MOVIMENTO ===
@export var velocidade: float = 110.0
@export var gravidade: float = 980.0

var direcao: int = 1

# === CONFIGURAÇÃO DE ALVO ===
@export var alcance_de_deteccao: float = 400.0
@export var alcance_ataque: float = 15.0
@export var margem_de_parada: float = 5.0
@export var dano: int = 45
@export var tempo_entre_ataques: float = 0.5

# === VARIÁVEL DE VIDA ===
@export var vida: int = 20

const VIDA_SCENE: PackedScene = preload("res://scenes/caixa_vida.tscn")

var player: CharacterBody2D = null
var pode_atacar: bool = true
var atacando: bool = false
var pode_causar_dano := false

# Controle do spawn
var spawn_concluido := false

func _ready() -> void:

	# Inicialização Estática
	if not is_initialized:
		randomize()
		drop_threshold = randi_range(5, 10)
		is_initialized = true

		print(
			"Drop de Vida inicializado. Próximo drop em: ",
			drop_threshold,
			" mortes."
		)

	player = get_tree().get_first_node_in_group("player")

	# =====================================
	# CORREÇÃO VISUAL DO SPAWN
	# =====================================

	# Garante escala correta
	$Sprite2D.scale.x = abs($Sprite2D.scale.x)

	# Animação inicial
	$AnimationPlayer.play("parado")

	# Espera 1 frame para estabilizar
	await get_tree().process_frame


func _physics_process(delta: float) -> void:

	if not is_instance_valid(player):
		return

	velocity.y += gravidade * delta

	# =================================
	# CONTROLE DE SPAWN
	# =================================
	if not spawn_concluido:

		# Enquanto estiver no ar
		if not is_on_floor():

			velocity.x = 0
			$AnimationPlayer.play("parado")

			move_and_slide()
			return

		# Tocou no chão
		spawn_concluido = true

	# =================================

	if player and is_instance_valid(player):
		seguir_player()
	else:
		player = get_tree().get_first_node_in_group("player")
		patrulhar()

	move_and_slide()


# ======================
# FUNÇÃO SEGUIR_PLAYER
# ======================
func seguir_player() -> void:

	if not is_instance_valid(player):
		return

	var distancia_x = abs(player.global_position.x - global_position.x)
	var distancia_y = abs(player.global_position.y - global_position.y)

	var vetor_para_player = player.global_position - global_position

	# Se o player estiver muito acima ou abaixo
	# ignora perseguição
	if distancia_y > 100:
		patrulhar()
		return

	# Direção do sprite
	direcao = 1 if vetor_para_player.x > 0 else -1
	$Sprite2D.scale.x = abs($Sprite2D.scale.x) * direcao
	# Travado em animação de dano/ataque
	if atacando or $AnimationPlayer.current_animation == "dano":

		velocity.x = 0

		if atacando:
			$AnimationPlayer.play("atacando")

		return

	# Detectou player
	if distancia_x <= alcance_de_deteccao:

		# Pode atacar
		if distancia_x <= alcance_ataque + margem_de_parada and distancia_y <= 32:

			velocity.x = 0

			if pode_atacar:
				atacar_player()
			else:
				$AnimationPlayer.play("parado")

		# Continua perseguindo
		else:

			velocity.x = velocidade * direcao

			# No chão -> andando
			if is_on_floor():
				$AnimationPlayer.play("andando")

			# No ar -> parado
			else:
				$AnimationPlayer.play("parado")

	# Fora do alcance
	else:
		patrulhar()


# ======================
# HITBOX DE DANO
# ======================
# ======================
# HITBOX DE DANO
# ======================
func _on_area_2d_atack_body_entered(body: Node2D) -> void:

	if not pode_causar_dano:
		return

	if body.is_in_group("player"):

		if body.has_method("_receber_dano"):

			body._receber_dano(dano, global_position)



# ======================
# FUNÇÃO ATACAR_PLAYER
# ======================
func atacar_player() -> void:

	if atacando or not pode_atacar:
		return

	atacando = true
	pode_atacar = false

	$AnimationPlayer.play("atacando")

	# Espera chegar no frame do golpe
	await get_tree().create_timer(0.3).timeout

	# Ativa dano
	pode_causar_dano = true

	# Janela do golpe
	var tempo_golpe := 0.15
	var tempo_passado := 0.0

	while tempo_passado < tempo_golpe:

		# verifica continuamente quem está dentro da hitbox
		for body in $Area_dano.get_overlapping_bodies():

			if body.is_in_group("player"):

				if body.has_method("_receber_dano"):

					body._receber_dano(dano, global_position)

		await get_tree().create_timer(0.1).timeout
		tempo_passado += 0.1

	# Desativa dano
	pode_causar_dano = false

	# Cooldown
	await get_tree().create_timer(tempo_entre_ataques).timeout

	pode_atacar = true
	atacando = false
# ======================
# FUNÇÃO PATRULHAR
# ======================
func patrulhar() -> void:

	if atacando or $AnimationPlayer.current_animation == "dano":

		velocity.x = 0
		return

	velocity.x = velocidade * direcao

	
	$Sprite2D.scale.x = abs($Sprite2D.scale.x) * direcao
	# No chão -> andando
	if is_on_floor():
		$AnimationPlayer.play("andando")

	# No ar -> parado
	else:
		$AnimationPlayer.play("parado")

	# RayCast controla direção
	if direcao == 1 and not $RayCast2DDir.is_colliding():
		direcao = -1

	elif direcao == -1 and not $RayCast2DEsq.is_colliding():
		direcao = 1


# ======================
# FUNÇÃO RECEBER DANO
# ======================
func _receber_dano(valor: int) -> void:

	vida -= valor

	print(
		"Inimigo levou ",
		valor,
		" de dano. Vida restante: ",
		vida
	)

	if damage_info:

		var damage_container = damage_info.instantiate()

		var label_texto = damage_container.get_node("damage_info")

		if label_texto:
			label_texto.text = str(valor)

		var pos_final: Vector2

		if damage_position:
			pos_final = damage_position.global_position
		else:
			pos_final = global_position
			
		damage_container.global_position = pos_final

		get_tree().current_scene.add_child(damage_container)

		var anim_player = damage_container.get_node_or_null("damage_info/anim")

		if anim_player:
			anim_player.play("damage_info")
		
	# Ainda vivo
	if vida > 0:

		if $AnimationPlayer.has_animation("dano"):
			$AnimationPlayer.play("dano")

	# Morreu
	else:
		morrer()


# ==================================
# FUNÇÃO MORRER
# ==================================
func morrer() -> void:

	print("Inimigo morrendo!")

	set_physics_process(false)
	set_process(false)

	if $AnimationPlayer.has_animation("morrendo"):

		$AnimationPlayer.play("morrendo")

		await $AnimationPlayer.animation_finished

		global.pontos()

	# ==================================
	# CONTROLE DE DROP
	# ==================================
	kills_since_last_drop += 1

	if kills_since_last_drop >= drop_threshold:

		print("Limite de drop atingido!")

		if VIDA_SCENE:

			var vida_drop = VIDA_SCENE.instantiate()

			get_tree().current_scene.add_child(vida_drop)

			vida_drop.global_position = global_position

		kills_since_last_drop = 0

		drop_threshold = randi_range(6, 9)

		print(
			"Novo limite de drop definido para: ",
			drop_threshold,
			" mortes."
		)

	else:

		print(
			"Faltam ",
			drop_threshold - kills_since_last_drop,
			" inimigos para o próximo drop."
		)

	queue_free()
