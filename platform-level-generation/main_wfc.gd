extends Node2D

@onready var generator : WFC2DGenerator = $WFC2DGenerator
@onready var result_map : TileMapLayer = $TileMapLayerResult

func _ready() -> void:
	if not generator.start_on_ready:
		generator.start()

	if generator.has_signal("done"):
		generator.done.connect(_on_generation_finished)


func _on_generation_finished() -> void:
	print("Génération WFC terminée.")
	_fix_grass_tiles()



# Post-traitement : force la tuile (7,0) (avec herbe) si rien n'est posé
# juste au-dessus d'une case solide, et (7,1) (sans herbe) sinon.
func _fix_grass_tiles() -> void:
	var used_rect := result_map.get_used_rect()

	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell := result_map.get_cell_atlas_coords(Vector2i(x, y))
			if cell != Vector2i(7, 0) and cell != Vector2i(7, 1):
				continue

			var above := result_map.get_cell_atlas_coords(Vector2i(x, y - 1))
			var source_id := result_map.get_cell_source_id(Vector2i(x, y))

			if above == Vector2i(1, 1) or above == Vector2i(-1, -1):
				# Vide explicite (1,1) ou case réellement vide -> herbe
				result_map.set_cell(Vector2i(x, y), source_id, Vector2i(7, 0))
			else:
				result_map.set_cell(Vector2i(x, y), source_id, Vector2i(7, 1))
