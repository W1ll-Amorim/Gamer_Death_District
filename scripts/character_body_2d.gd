extends CharacterBody2D

var velocidade : = 400
var gravidade  : = 30
var forca_pulo : = 650

func _process(_delta: float) -> void:
	_aplicar_gravidade()
	_processar_movimento()
	_processar_pulo()
	move_and_slide()
	_processar_animacao()
	
	
func _aplicar_gravidade() -> void:
	velocity.y += gravidade
	
func _processar_movimento() -> void:
	velocity.x = 0
	
	if Input.is_action_pressed("move_left"):
		velocity.x = - velocidade
		$Sprite2D.scale.x = -abs($Sprite2D.scale.x)
		
	elif Input.is_action_pressed("move_right"):
		velocity.x = velocidade
		$Sprite2D.scale.x = abs($Sprite2D.scale.x)

func _processar_pulo() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -forca_pulo


func _processar_animacao() -> void:
	
	if not is_on_floor():
		$AnimationPlayer.play("pulando")
		return
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("atirando")
		if ($Sprite2D.scale.x <0):
			pass
		else:
			pass
			
	if $AnimationPlayer.current_animation == "atirando":
		velocity.x = 0
	else:
		if velocity.x == 0:
			$AnimationPlayer.play("parado")
		else:
			$AnimationPlayer.play("correndo")
			
	if Input.is_action_pressed("move_down"):
		$AnimationPlayer.play("abaixando")
