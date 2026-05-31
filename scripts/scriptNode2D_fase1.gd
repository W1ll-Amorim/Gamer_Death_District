extends Node2D

# === CONFIGURAÇÕES ===
@export var inimigos: Array[PackedScene] = [
	preload("res://scenes/zombie_01.tscn"),
	preload("res://scenes/zombie_02.tscn"),
	preload("res://scenes/zombie_feme.tscn"),
	preload("res://scenes/zombie_feme_02.tscn")
]

@export var tempo_spawn: float = 2.60  # intervalo entre spawns
@export var margem_spawn: float = 50  # distância fora da câmera

# === VARIÁVEIS INTERNAS ===
var timer: Timer                      # Timer para spawn de inimigos
var cronometro: Timer                 # Timer que controla o tempo de jogo
var tempo_label: Label                # Label que mostra o tempo
var tempo_total: float = 0.0          # Contador do tempo de jogo


# ================================
# === FUNÇÃO READY PRINCIPAL ===
# ================================
func _ready():
	# === TIMER DE SPAWN DOS INIMIGOS ===
	timer = Timer.new()
	timer.wait_time = tempo_spawn
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_spawn_inimigo)

	# === TIMER DE CRONÔMETRO ===
	cronometro = Timer.new()
	cronometro.wait_time = 0.1
	cronometro.autostart = true
	cronometro.one_shot = false
	add_child(cronometro)
	cronometro.start()

	# === LABEL DO CRONÔMETRO (fixa na câmera) ===
		# === LABEL DO CRONÔMETRO (fixa na câmera) ===
	tempo_label = Label.new()
	tempo_label.text = "00:00.00"

	# Centralizar no topo da tela
	var viewport_size = get_viewport_rect().size
	tempo_label.position = Vector2(viewport_size.x / 2, 20)
	tempo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# === ESTILO DA FONTE ===
	var font_theme = Theme.new()
	var dynamic_font = FontFile.new()
	dynamic_font = load("res://fonts/PixelPurl.ttf")  # coloque o caminho da sua fonte aqui

	font_theme.set_font("font", "Label", dynamic_font)
	font_theme.set_font_size("font_size", "Label", 32) # tamanho da fonte
	font_theme.set_color("font_color", "Label", Color(1.0, 1.0, 1.0)) # cor amarela clara

	tempo_label.theme = font_theme

	# === ADICIONAR AO HUD (CanvasLayer fixo) ===
	var hud_layer = CanvasLayer.new()
	hud_layer.layer = 10
	hud_layer.add_child(tempo_label)
	add_child(hud_layer)

# ==========================
# === ATUALIZAÇÃO DO TEMPO ===
# ==========================
func _process(delta: float) -> void:
	if not cronometro or cronometro.is_stopped():
		return

	tempo_total += delta
	_atualizar_label_tempo(tempo_total)


# ==========================
# === FUNÇÃO AUXILIAR ===
# ==========================
func _atualizar_label_tempo(tempo_em_segundos: float) -> void:
	if not tempo_label:
		return

	var minutos: int = floor(tempo_em_segundos / 60.0)
	var segundos: int = fmod(tempo_em_segundos, 60.0)
	#var milisegundos: int = fmod(tempo_em_segundos * 100, 100)
	var tempo_formatado: String = "%02d:%02d" % [minutos, segundos]

	tempo_label.text = tempo_formatado


# ==========================
# === FUNÇÃO DE SPAWN ===
# ==========================
func _spawn_inimigo():
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		push_warning("Nenhuma câmera 2D encontrada!")
		return

	var screen_size = get_viewport_rect().size
	var camera_center = camera.get_screen_center_position()
	var view_rect = Rect2(
		camera_center - (screen_size / 2),
		screen_size
	)

	var side = randi_range(0, 3)
	var spawn_pos = Vector2.ZERO

	match side:
		0: spawn_pos = Vector2(randf_range(view_rect.position.x, view_rect.end.x), view_rect.position.y - margem_spawn)
		1: spawn_pos = Vector2(randf_range(view_rect.position.x, view_rect.end.x), view_rect.end.y + margem_spawn)
		2: spawn_pos = Vector2(view_rect.position.x - margem_spawn, randf_range(view_rect.position.y, view_rect.end.y))
		3: spawn_pos = Vector2(view_rect.end.x + margem_spawn, randf_range(view_rect.position.y, view_rect.end.y))

	var cena_inimigo = inimigos.pick_random()
	var novo_inimigo = cena_inimigo.instantiate()
	novo_inimigo.position = spawn_pos

	get_parent().add_child(novo_inimigo)
	print("Inimigo spawnado em:", spawn_pos)
	
