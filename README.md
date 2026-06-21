# Platform\_Level\_Generation

# IAS — Génération de niveaux de plateformer

**Noms :** HALEY Maxime & HEYSCH Benjamin

## 1.Approche constructive

Le niveau est généré colonne par colonne, en appliquant un ensemble de règles au moment de remplir chaque case :

- La rangée du bas est toujours pleine (sol garanti).
- Pas de plafond généré sous une hauteur fixe depuis le haut.
- Pas de bloc isolé d'une seule case.
- Pas de mur de plus de 2 cases de haut d'affilée.
- Un écart de 2 cases est imposé entre deux plateformes superposées verticalement, pour garantir un passage vertical.
- En dehors de ces règles, les cases sont remplies aléatoirement selon un paramètre de taux de remplissage FILL_RATE.

Après la génération `enforce_vertical_clearance` repasse sur la map et retire toute case solide qui ne laisserait qu'1 case d'écart vertical au-dessus d'une autre case solide.

Une fonction fitness évalue la map générée sur 3 critères, combinés en un score pondéré unique :

- **Plateformes** — proportion de plateformes faisant au moins 2 cases de large (jouables) parmi toutes les plateformes trouvées.
- **Densité** — à quel point le taux de remplissage réel se rapproche du taux de remplissage cible.
- **Chemin** — définit si le niveau est globalement jouable, en partant du point de spawn jusqu'à l'arrivée et en prenant en compte le chemin par les plateformes.

## 2. Wave Function Collapse

On a choisi de partir vers Wave Function Collapse avec le plugin `godot-constraint-solving`.

- Une petite carte d'exemple est dessinée à la main (`positive_sample`), et le générateur en apprend les règles d'adjacence entre tuiles, puis remplit une carte cible (`target`) de la taille voulue.
- En l'état, WFC peut générer des maps ne reprenant pas forcément les règles qu'on a cherché à établir vu que l'échantillon d'exemple est trop petit.
- Pour garder une structure cohérente avec la partie 1, on a ajouté `WFC2DPreconditionPlatformer` dans la même idée que la class dungeon donnée en exemple du plugin. La précondition fait que le WFC calcul à l'avance où il peut mettre les tuiles et ne les dispose que si elles suivent les règles.
- Comme pour la première partie on fait une fonction qui passe après la génération pour nettoyer les problèmes. Ici, la génération ne prenait pas la bonne tuile et donc on a fait en sorte que quand on détecte un sol au dessus, on met de la terre, sinon on met de l'herbe.
- Les mêmes fonctions fitness que la partie 1 (plateformes, densité, chemin) sont réutilisées pour noter le résultat du WFC, en convertissant la tilemap de résultat dans le même format de tableau attendu par ces fonctions.

## 3. Remarques / limites connues

- La faisabilité d'un saut dans la fonction fitness est approximée par une ligne droite entre deux points d'appui, pas par une vraie trajectoire de saut. Il aurait fallu qu'on fasse plutôt un graphe des sauts possibles mais dans la limite de temps on a préféré ne pas développer cette idée et plutôt prendre indépendamment la hauteur de saut et la longueur.
- Si une map n'a aucune plateforme en hauteur, le score de chemin retombe sur une simple vérification d'accessibilité au sol, c'est peu probable mais ça peut arriver et dans ce cas on aura une bonne note pour une map pas géniale.