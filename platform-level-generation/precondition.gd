extends WFC2DPrecondition
## Précondition pour la génération de niveaux de plateformer.
##
## Impose une structure sol/vide selon les règles établies dans
## generate_ruled_map() (partie 1 du projet), avant que le WFC ne choisisse
## les tuiles précises à utiliser pour chaque case solide ou vide.
class_name WFC2DPreconditionPlatformer

# Domaines de tuiles : solid_domain regroupe toutes les tuiles "pleines"
# (sol, plateformes), empty_domain regroupe les tuiles "vides" (ciel).
# Remplis depuis l'exemple positive_sample, comme walls_domain/
# passable_domain dans l'exemple donjon.
var solid_domain: WFCBitSet
var empty_domain: WFCBitSet

# Paramètres repris directement de main.gd (generate_ruled_map). Idéalement,
# synchronise ces valeurs avec les constantes MAP_WIDTH/MAP_HEIGHT/FILL_RATE
# de ton script existant, pour ne pas dupliquer les réglages à deux endroits.
var fill_rate: float = 0.07
var ceiling_clearance: int = 17  # cf. "elif y < MAP_HEIGHT - 17" dans main.gd

var rect: Rect2i
var state: PackedByteArray

const STATE_SOLID = 0
const STATE_EMPTY = 1

func coord_to_id(c: Vector2i) -> int:
	assert(rect.has_point(c))
	var rel_c: Vector2i = c - rect.position
	return rel_c.x + rel_c.y * rect.size.x

func id_to_coord(i: int) -> Vector2i:
	var szx: int = rect.size.x
	@warning_ignore("integer_division")
	return Vector2i(i % szx, i / szx)

func _set_state(c: Vector2i, value: int) -> void:
	state[coord_to_id(c)] = value

func _get_state(c: Vector2i) -> int:
	return state[coord_to_id(c)]

# Identique en esprit à learn_classes_from_map() de l'exemple donjon : on
# apprend quelles tuiles de positive_sample sont "solides" et lesquelles
# sont "vides", à partir de deux rangées de l'exemple (rangée 0 = vide,
# rangée 1 = solide), plutôt que de coder les indices de tuiles en dur.
func learn_classes_from_map(
	mapper: WFCMapper2D,
	map: Node,
):
	assert(mapper.supports_map(map))

	var used_rect := mapper.get_used_rect(map)
	assert(used_rect.has_area())
	assert(used_rect.size.y == 2)  # rangée 0 = vide, rangée 1 = solide

	empty_domain = WFCBitSet.new(mapper.size())
	for x_off in range(used_rect.size.x):
		var p := used_rect.position + Vector2i(x_off, 0)
		var tile := mapper.read_cell(map, p)
		if tile >= 0:
			empty_domain.set_bit(tile)

	solid_domain = WFCBitSet.new(mapper.size())
	for x_off in range(used_rect.size.x):
		var p := used_rect.position + Vector2i(x_off, 1)
		var tile := mapper.read_cell(map, p)
		if tile >= 0:
			solid_domain.set_bit(tile)

	assert(not solid_domain.is_empty())
	assert(not empty_domain.is_empty())

# Variante par méta-attributs de tuiles, en miroir de learn_classes() dans
# l'exemple donjon. Utile si tu préfères marquer chaque tuile du TileSet
# individuellement (custom data layer) plutôt que de dessiner une carte à
# 2 rangées dédiée.
func learn_classes(
	mapper: WFCMapper2D,
	empty_class: String = "wfc_platformer_empty",
	solid_class: String = "wfc_platformer_solid",
):
	empty_domain = WFCBitSet.new(mapper.size())
	solid_domain = WFCBitSet.new(mapper.size())

	for i in range(mapper.size()):
		if mapper.read_tile_meta_boolean(i, empty_class):
			empty_domain.set_bit(i)
		if mapper.read_tile_meta_boolean(i, solid_class):
			solid_domain.set_bit(i)

	assert(not empty_domain.is_empty())

	if solid_domain.is_empty():
		solid_domain = empty_domain.invert()
		assert(not solid_domain.is_empty())

# Reprend très exactement la logique de generate_ruled_map(), mais ne
# produit que la couche "structure" (solide/vide), sans choisir de tuile
# précise — c'est le rôle du WFC une fois la précondition appliquée.
func prepare():
	assert(rect.has_area())

	var w: int = rect.size.x
	var h: int = rect.size.y
	state.resize(rect.get_area())

	for local_x in range(w):
		for local_y in range(h):
			var c := rect.position + Vector2i(local_x, local_y)
			var is_solid: bool

			if local_y == h - 1:
				# Toujours un sol
				is_solid = true
			elif local_y < h - ceiling_clearance:
				# Pas de plafond
				is_solid = false
			elif local_x > 1 \
					and _get_state(c - Vector2i(2, 0)) == STATE_EMPTY \
					and _get_state(c - Vector2i(1, 0)) == STATE_SOLID:
				# Pas de cube isolé (min 2 tuiles de largeur)
				is_solid = true
			elif local_y == h - 2 \
					and _get_state(c - Vector2i(0, 1)) == STATE_SOLID \
					and _get_state(c - Vector2i(0, 2)) == STATE_SOLID:
				# Pas de mur de plus de 3 tuiles
				is_solid = false
			elif local_y < h - 2 \
					and _get_state(c - Vector2i(0, 1)) == STATE_EMPTY \
					and _get_state(c - Vector2i(0, 2)) == STATE_SOLID:
				# Passage de deux tuiles entre les plateformes
				is_solid = false
			else:
				is_solid = randf() < fill_rate

			_set_state(c, STATE_SOLID if is_solid else STATE_EMPTY)

	_enforce_vertical_clearance()

# Portage direct de enforce_vertical_clearance() dans main.gd : si une case
# pleine repose sur du vide, mais que 2 cases au-dessus est aussi plein,
# l'écart n'est que d'1 case -> on vide la case.
func _enforce_vertical_clearance() -> void:
	var w: int = rect.size.x
	var h: int = rect.size.y

	for local_x in range(w):
		for local_y in range(2, h - 1):
			var c := rect.position + Vector2i(local_x, local_y)
			if _get_state(c) == STATE_SOLID \
					and _get_state(c - Vector2i(0, 1)) == STATE_EMPTY \
					and _get_state(c - Vector2i(0, 2)) == STATE_SOLID:
				_set_state(c, STATE_EMPTY)

func read_domain(coords: Vector2i) -> WFCBitSet:
	assert(state.size() == rect.get_area())

	if not rect.has_point(coords):
		return null

	match _get_state(coords):
		STATE_SOLID:
			return solid_domain
		STATE_EMPTY:
			return empty_domain
		_:
			return null
