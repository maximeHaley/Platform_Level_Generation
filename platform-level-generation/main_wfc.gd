extends Node2D

@onready var generator : WFC2DGenerator = $WFC2DGenerator

func _ready() -> void:
	if not generator.start_on_ready:
		generator.start()

	if generator.has_signal("generation_finished"):
		generator.generation_finished.connect(_on_generation_finished)


func _on_generation_finished() -> void:
	print("Génération WFC terminée.")
