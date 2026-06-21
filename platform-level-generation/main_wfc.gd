extends Node2D

@onready var generator : WFC2DGenerator = $WFC2DGenerator
@onready var result_map : TileMapLayer = $TileMapLayerResult


const MAP_WIDTH = 72
const MAP_HEIGHT = 20
const FILL_RATE = 0.07
const JUMP_MAX_DIST = 5
const JUMP_MAX_HEIGHT = 3

func _ready() -> void:
	if not generator.start_on_ready:
		generator.start()
	if generator.has_signal("done"):
		generator.done.connect(_on_generation_finished)


func _on_generation_finished() -> void:
	print("Génération WFC terminée.")
	_fix_grass_tiles()
	var wfc_map := _convert_result_to_array()

	_place_spawn_goal_markers(wfc_map)

	var score = fitness(wfc_map)
	print("Score map WFC : %.3f" % score)
	print("  - Plateformes : %.3f" % fitness_platforms(wfc_map))
	print("  - Densité     : %.3f" % fitness_density(wfc_map))
	print("  - Chemin      : %.3f" % fitness_path(wfc_map))


func _place_spawn_goal_markers(map: Array) -> void:
	var start := _find_spawn(map, 0)
	var goal  := _find_spawn(map, MAP_WIDTH - 2)

	if start != Vector2i(-1, -1):
		result_map.set_cell(start, 0, Vector2i(12, 1))
	if goal != Vector2i(-1, -1):
		result_map.set_cell(goal, 0, Vector2i(17, 9))


# Post-traitement : force la tuile (7,0) (avec herbe) si rien n'est posé
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
				result_map.set_cell(Vector2i(x, y), source_id, Vector2i(7, 0))
			else:
				result_map.set_cell(Vector2i(x, y), source_id, Vector2i(7, 1))

func _convert_result_to_array() -> Array:
	var map = []
	for x in MAP_WIDTH:
		var column = []
		for y in MAP_HEIGHT:
			var cell := result_map.get_cell_atlas_coords(Vector2i(x, y))
			# Solide si c'est une des deux variantes de sol (7,0)/(7,1).
			if cell == Vector2i(7, 0) or cell == Vector2i(7, 1):
				column.append(1)
			else:
				column.append(0)
		map.append(column)
	return map

func fitness(map: Array) -> float:
	var score_platforms = fitness_platforms(map)
	var score_density = fitness_density(map)
	var score_path = fitness_path(map)
	return 0.3*score_platforms + 0.4*score_density + 0.3*score_path

func fitness_platforms(map: Array) -> float:
	var total_platforms = 0
	var playable_platforms = 0

	for y in range(0, MAP_HEIGHT - 1):
		var run = 0
		for x in MAP_WIDTH:
			if map[x][y] == 1:
				run += 1
			else:
				if run >= 2:
					playable_platforms += 1
				if run > 0:
					total_platforms += 1
				run = 0
		if run >= 2:
			playable_platforms += 1
		if run > 0:
			total_platforms += 1
	if total_platforms == 0:
		return 0.0
	return float(playable_platforms)/float(total_platforms)

func fitness_density(map: Array) -> float:
	var total_cells = MAP_HEIGHT*MAP_WIDTH
	var bloc_cells = 0

	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			if map[x][y] == 1:
				bloc_cells += 1
	var density = float(bloc_cells)/float(total_cells)
	if density == FILL_RATE:
		return 1
	else:
		if density < FILL_RATE:
			return (1 - (FILL_RATE - density))
		else:
			return (1 - (density - FILL_RATE))


func fitness_path(map: Array) -> float:
	var start = _find_spawn(map, 0)
	var goal  = _find_spawn(map, MAP_WIDTH - 2)

	if start == Vector2i(-1, -1) or goal == Vector2i(-1, -1):
		return 0.0

	var platform_tops = _find_all_platform_tops(map)

	var elevated_tops = []
	for p in platform_tops:
		if p.y < MAP_HEIGHT - 2:
			elevated_tops.append(p)

	if not platform_tops.has(start):
		platform_tops.append(start)
	if not platform_tops.has(goal):
		platform_tops.append(goal)

	var visited = {}
	var queue = [start]
	visited[start] = true

	while queue.size() > 0:
		var current = queue.pop_front()

		for other in platform_tops:
			if visited.has(other):
				continue
			if _is_jump_possible(map, current, other):
				visited[other] = true
				queue.append(other)

	if not visited.has(goal):
		return 0.0

	if elevated_tops.size() == 0:
		return 1.0

	var reached_elevated = 0
	for p in elevated_tops:
		if visited.has(p):
			reached_elevated += 1

	return float(reached_elevated) / float(elevated_tops.size())


func _find_spawn(map: Array, x: int) -> Vector2i:
	for y in range(MAP_HEIGHT - 1, -1, -1):
		if map[x][y] == 0:
			return Vector2i(x, y)
	return Vector2i(-1, -1)


func _find_all_platform_tops(map: Array) -> Array:
	var tops = []
	for x in MAP_WIDTH:
		for y in range(0, MAP_HEIGHT - 1):
			if map[x][y] == 0 and map[x][y + 1] == 1:
				tops.append(Vector2i(x, y))
	return tops


func _is_jump_possible(map: Array, from: Vector2i, to: Vector2i) -> bool:
	var dx = abs(to.x - from.x)
	var dy = from.y - to.y

	if dx == 0:
		return false
	if dx > JUMP_MAX_DIST:
		return false
	if dy > JUMP_MAX_HEIGHT or dy < -JUMP_MAX_HEIGHT:
		return false

	var step_x = 1 if to.x > from.x else -1
	var steps = dx
	for i in range(1, steps + 1):
		var t = float(i) / float(steps)
		var x = from.x + step_x * i
		var y = round(lerp(float(from.y), float(to.y), t))
		if x < 0 or x >= MAP_WIDTH or y < 0 or y >= MAP_HEIGHT:
			return false
		if map[x][y] == 1:
			return false

	return true
