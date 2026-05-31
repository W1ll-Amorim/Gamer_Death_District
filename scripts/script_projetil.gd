extends Area2D

# === CONFIGURAÇÕES ===
@export var velocidade: float = 1000.0
@export var dano: int = 10
var direcao: int = 1

# === CENAS ===
var hit_scene: PackedScene = preload("res://scenes/efeito_hit.tscn")

func _ready() -> void:
	# Garante que os sinais estejam conectados
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))

	_tocar_som_disparo()


func _process(delta: float) -> void:
	global_position.x += velocidade * direcao * delta


# ------------------------
# COLISÕES
# ------------------------
func _on_body_entered(body: Node) -> void:
	var pos_hit := global_position

	if body.is_in_group("inimigo"):
		_explodir_safe(body, pos_hit)
		return

	if body.is_in_group("parede"):
		_efeito_hit(pos_hit)
		call_deferred("queue_free")


func _on_area_entered(area: Area2D) -> void:
	var pos_hit := global_position

	if area.is_in_group("inimigo"):
		_explodir_safe(area, pos_hit)
		return

	if area.is_in_group("projetil_inimigo"):
		call_deferred("queue_free")


# ------------------------
# SOM DO DISPARO (FUNCIONA FORA DA TELA)
# ------------------------
func _tocar_som_disparo() -> void:
	var som_original = $AudioStreamPlayer2D
	if not som_original or not som_original.stream:
		return

	# Criar som temporário independente
	var som_temp := AudioStreamPlayer2D.new()
	som_temp.stream = som_original.stream
	som_temp.volume_db = som_original.volume_db
	som_temp.pitch_scale = som_original.pitch_scale
	som_temp.global_position = global_position

	# SOM FUNCIONA MESMO FORA DA TELA
	som_temp.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().get_root().add_child(som_temp)
	som_temp.play()

	som_temp.connect("finished", Callable(som_temp, "queue_free"))


# ------------------------
# UTILITÁRIOS
# ------------------------
func _find_inimigo_root(node: Node) -> Node:
	var cur := node
	while cur and not cur.is_class("CharacterBody2D"):
		if cur.get_parent() == null:
			break
		cur = cur.get_parent()
	if cur and cur.is_class("CharacterBody2D"):
		return cur
	return node


func _explodir_safe(alvo: Node, pos_hit: Vector2) -> void:
	var raiz := _find_inimigo_root(alvo)
	var pos_raiz := Vector2.ZERO

	if is_instance_valid(raiz):
		pos_raiz = raiz.global_position

	call_deferred("_finalizar_explosao", raiz, pos_raiz, pos_hit, dano)


# ------------------------
# EXECUÇÃO ADIADA — DANO
# ------------------------
func _finalizar_explosao(raiz_inimigo: Node, pos_raiz: Vector2, pos_hit: Vector2, valor_dano: int) -> void:
	_efeito_hit(pos_hit)

	if is_instance_valid(raiz_inimigo) and raiz_inimigo.has_method("_receber_dano"):
		raiz_inimigo._receber_dano(valor_dano)

	call_deferred("queue_free")


# ------------------------
# EFEITO DE HIT
# ------------------------
func _efeito_hit(posicao: Vector2) -> void:
	if not hit_scene:
		return

	var hit = hit_scene.instantiate()
	get_tree().current_scene.add_child(hit)

	var ajuste_x := -30.0
	var ajuste_y := -40.0

	hit.global_position = posicao + Vector2(ajuste_x, ajuste_y)
	hit.rotation = rotation


# ------------------------
# SAIU DA TELA
# ------------------------
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	call_deferred("queue_free")
