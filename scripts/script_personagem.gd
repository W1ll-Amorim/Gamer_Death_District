extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0

const PROJETIL_SCENE: PackedScene = preload("res://scenes/projetil.tscn")

var pode_atirar: bool = true
var cooldown_tiro: float = 0.3

var pulos_max: int = 2
var pulos_restantes: int = 2

func _physics_process(delta: float) -> void:
	aplicar_gravidade(delta)
	processar_movimento()
	processar_pulo()
	processar_animacao()
	move_and_slide()

func aplicar_gravidade(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
		pulos_restantes = pulos_max

func processar_movimento() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")

	if $AnimationPlayer.current_animation in ["atirando", "atirando_ar", "abaixando"]:
		velocity.x = 0
		return

	velocity.x = input_dir * speed

	if input_dir < 0:
		$Sprite2D.scale.x = -abs($Sprite2D.scale.x)
	elif input_dir > 0:
		$Sprite2D.scale.x = abs($Sprite2D.scale.x)

func processar_pulo() -> void:
	if Input.is_action_just_pressed("jump") and pulos_restantes > 0:
		velocity.y = jump_force
		pulos_restantes -= 1
		$AnimationPlayer.play("pulando")

func processar_animacao() -> void:
	var current_anim = $AnimationPlayer.current_animation

	if current_anim in ["atirando", "atirando_ar", "abaixando"]:
		return

	if Input.is_action_pressed("move_down"):
		velocity.x = 0
		$AnimationPlayer.play("abaixando")
		return

	if Input.is_action_just_pressed("shoot") and pode_atirar:
		atirar()
		return

	if not is_on_floor():
		if current_anim != "pulando":
			$AnimationPlayer.play("pulando")
		return

	if abs(velocity.x) > 10:
		$AnimationPlayer.play("correndo")
	else:
		$AnimationPlayer.play("parado")

func atirar() -> void:
	if not pode_atirar:
		return
	pode_atirar = false

	# ---- TOCA O SOM DIRETO NO PLAYER (nunca some) ----
	if $SomTiro:
		$SomTiro.stop()  # evita sobreposição feia
		$SomTiro.play()

	# ---- ANIMAÇÕES ----
	if is_on_floor():
		$AnimationPlayer.play("atirando")
	else:
		$AnimationPlayer.play("atirando_ar")

	# ---- INSTANCIA PROJETIL ----
	if PROJETIL_SCENE == null:
		push_error("⚠️ Erro: Cena do projétil não encontrada!")
		pode_atirar = true
		return

	var disparo = PROJETIL_SCENE.instantiate()
	if disparo == null:
		push_error("⚠️ Falha ao instanciar o projétil!")
		pode_atirar = true
		return

	get_tree().current_scene.add_child(disparo)

	if $Sprite2D.scale.x < 0:
		disparo.global_position = $Marker2D_esq.global_position
		disparo.direcao = -1
	else:
		disparo.global_position = $Marker2D_dir.global_position
		disparo.direcao = 1

	velocity.x = 0

	await get_tree().create_timer(cooldown_tiro).timeout
	pode_atirar = true


# ======================================
#     SISTEMA DE DANO (COM FILTRO)
# ======================================
func _receber_dano(valor: int, origem_posicao: Vector2) -> void:

	global.vida_player -= valor

	print("Player levou ", valor, " de dano.")
	print("Vida atual: ", global.vida_player)

	if global.vida_player <= 0:
		morrer()

func morrer() -> void:
	print("💀 Player morreu!")
	global.resetar()
	global.remover_inimigos()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	queue_free()
