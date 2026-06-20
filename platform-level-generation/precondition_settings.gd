extends WFC2DPrecondition2DNullSettings
## Settings pour la précondition qui impose une structure de plateformer
## (sol garanti, pas de plafond, clearance verticale) avant que le WFC ne
## choisisse les tuiles précises. Reprend les règles de generate_ruled_map()
## de la partie 1 du projet.
class_name WFC2DPreconditionPlatformerSettings

@export_group("Platformer generator settings")

## Taux de remplissage aléatoire utilisé là où aucune règle stricte ne
## s'applique (équivalent de FILL_RATE dans main.gd).
@export_range(0.0001, 1.0)
var fill_rate: float = 0.07

## Hauteur (en tuiles, depuis le bas de la zone) à partir de laquelle aucun
## plafond ne doit être généré. Équivalent de "MAP_HEIGHT - 17" dans
## generate_ruled_map() : ici on exprime directement la valeur soustraite
## (17), pas la hauteur totale, pour rester indépendant de la taille exacte
## de la zone générée.
@export
var ceiling_clearance: int = 17

@export_group("Tile classes")

## Nom de l'attribut meta / custom data layer qui marque les tuiles "vides".
@export
var empty_class: String = "wfc_platformer_empty"

## Nom de l'attribut meta / custom data layer qui marque les tuiles "solides".
@export
var solid_class: String = "wfc_platformer_solid"

## Si renseigné, la précondition apprendra les classes de tuiles
## (vide/solide) depuis ce nœud plutôt que depuis les meta des tuiles.
## Première rangée de la carte = tuiles vides.
## Deuxième rangée = tuiles solides. Peut être vide (toutes les tuiles hors
## première rangée seront alors considérées comme solides).
@export_node_path
var classes_map: NodePath

func create_precondition(parameters: WFC2DPrecondition2DNullSettings.CreationParameters) -> WFC2DPrecondition:
	var res: WFC2DPreconditionPlatformer = WFC2DPreconditionPlatformer.new()

	res.rect = parameters.problem_settings.rect

	var mapper := parameters.problem_settings.rules.mapper

	if classes_map != null and not classes_map.is_empty():
		var map_node := parameters.generator_node.get_node(classes_map)
		res.learn_classes_from_map(mapper, map_node)
	else:
		res.learn_classes(mapper, empty_class, solid_class)

	assert(fill_rate > 0.0 and fill_rate < 1.0)
	res.fill_rate = fill_rate

	assert(ceiling_clearance > 0)
	res.ceiling_clearance = ceiling_clearance

	return res
