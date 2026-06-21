extends Node2D

# Paramètres
const MAP_WIDTH = 72
const MAP_HEIGHT = 20
const FILL_RATE = 0.07
const JUMP_MAX_DIST = 4    # portée horizontale max d'un saut
const JUMP_MAX_HEIGHT = 3  # différence de hauteur max franchissable 

@onready var tilemap : TileMapLayer = $TileMapLayerConstructive

# Map courante
var current_map : Array = []

func _ready() -> void:
	randomize()
	current_map = generate_ruled_map()
	draw_map(current_map)
	
	# Test fitness
	var score = fitness(current_map)
	print("Score map aléatoire : %.3f" % score)
	print("  - Plateformes : %.3f" % fitness_platforms(current_map))
	print("  - Densité     : %.3f" % fitness_density(current_map))
	print("  - Chemin      : %.3f" % fitness_path(current_map))


func generate_ruled_map() -> Array:
	var map = []
	for x in MAP_WIDTH:
		var column = []
		for y in MAP_HEIGHT:
			# Toujours avoir un sol
			if y == MAP_HEIGHT - 1:
				column.append(1)
			# Pas de plafond
			elif y < MAP_HEIGHT - 17:
				column.append(0)
			# Pas de cube isolé (min 2tuiles de largeur)
			elif x > 1 and map[x-2][y]==0 and map[x-1][y]==1:
				column.append(1)
			# Pas de mur de plus de 3 tuiles
			elif y == MAP_HEIGHT-2 and column[y-1] == 1 and column[y-2] == 1:
				column.append(0)
			# Passage de deux tuiles entre les plateformes
			elif y < MAP_HEIGHT-2 and column[y-1] == 0 and column[y-2] == 1:
				column.append(0)
			else:
				column.append(1 if randf() < FILL_RATE else 0)
		map.append(column)
	enforce_vertical_clearance(map)
	return map

#Pour être sûr que l'écart en hauteur est bien de 2 pour 2 blocs non reliés
func enforce_vertical_clearance(map: Array) -> void:
	for x in MAP_WIDTH:
		for y in range(2, MAP_HEIGHT - 1):
			if map[x][y] == 1 and map[x][y-1] == 0:
				# Si le bloc 2 cases au-dessus est aussi plein, l'écart n'est que d'1 case
				if map[x][y-2] == 1:
					map[x][y] = 0 

# Affichage de la map
func draw_map(map: Array) -> void:
	tilemap.clear()
	for x in MAP_WIDTH:
		for y in MAP_HEIGHT:
			if map[x][y] == 1:
				if map[x][y-1] == 0:
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(7, 0))
				else :
					tilemap.set_cell(Vector2i(x, y), 0, Vector2i(7, 1))
			else:
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 1))


# Fonction fitness, qui donne un score global
func fitness(map: Array) -> float:
	var score_platforms = fitness_platforms(map)
	var score_density = fitness_density(map)
	var score_path = fitness_path(map)
	return 0.3*score_platforms + 0.4*score_density + 0.3*score_path
	
# Critère de plateformes, favorise les grandes plateformes
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
		# fin de ligne
		if run >= 2:
			playable_platforms += 1
		if run > 0:
			total_platforms += 1 
	if total_platforms == 0:
		return 0.0
	return float(playable_platforms)/float(total_platforms)

# Critère de densité, doit correspondre au taux de remplissage
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
	tilemap.set_cell(start, 0, Vector2i(12, 1))
	var goal  = _find_spawn(map, MAP_WIDTH - 2)
	tilemap.set_cell(goal, 0, Vector2i(17, 9))
 
	if start == Vector2i(-1, -1) or goal == Vector2i(-1, -1):
		return 0.0
 
	# Repérer tous les sommets de plateforme
	var platform_tops = _find_all_platform_tops(map)
 
	# Pour faire la différence entre le sol et une plateforme
	var elevated_tops = []
	for p in platform_tops:
		if p.y < MAP_HEIGHT - 2:
			elevated_tops.append(p)
 
	if not platform_tops.has(start):
		platform_tops.append(start)
	if not platform_tops.has(goal):
		platform_tops.append(goal)
 
	#Parcours en largeur
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
 
	#Cas où on n'a aucune plateforme donc un sol plat
	if elevated_tops.size() == 0:
		return 1.0 if visited.has(goal) else 0.0
 
	var reached_elevated = 0
	for p in elevated_tops:
		if visited.has(p):
			reached_elevated += 1
 
	return float(reached_elevated) / float(elevated_tops.size())
 
 
# Regarde pour toutes les colonnes les endroit ou le perso peut se poser sur un bloc
func _find_all_platform_tops(map: Array) -> Array:
	var tops = []
	for x in MAP_WIDTH:
		for y in range(0, MAP_HEIGHT - 1):
			if map[x][y] == 0 and map[x][y + 1] == 1:
				tops.append(Vector2i(x, y))
	return tops
 
 
#Teste si le saut est possible en longueur/hauteur
func _is_jump_possible(map: Array, from: Vector2i, to: Vector2i) -> bool:
	var dx = abs(to.x - from.x)
	var dy = from.y - to.y
 
	if dx == 0:
		return false  # même colonne, pas un saut horizontal
	if dx > JUMP_MAX_DIST:
		return false
	if dy > JUMP_MAX_HEIGHT or dy < -JUMP_MAX_HEIGHT:
		return false
 
	# Vérifie qu'il n'y a pas de bloc qui bloque la trajectoire du saut
	var step_x = 1 if to.x > from.x else -1
	var steps = dx
	for i in range(1, steps + 1):
		var t = float(i) / float(steps)
		var x = from.x + step_x * i
		var y = round(lerp(float(from.y), float(to.y), t))
		if x < 0 or x >= MAP_WIDTH or y < 0 or y >= MAP_HEIGHT:
			continue
		if map[x][y] == 1:
			return false
 
	return true

# Cherche la première case libre au dessus du sol
func _find_spawn(map: Array, x: int) -> Vector2i:
	for y in range(MAP_HEIGHT - 1, -1, -1):
		if map[x][y] == 0:
			return Vector2i(x, y)
	return Vector2i(-1, -1)
