extends ParallaxBackground


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	$ProgressBar.value = global.vida_player
	
