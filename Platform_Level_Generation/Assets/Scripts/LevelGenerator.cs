using UnityEngine;
using UnityEngine.Tilemaps;
public class LevelGenerator : MonoBehaviour
{
    //parametres de la scene
    /*public Tilemap backgroundMap;
    public Tilemap environmentMap;
*/
    public TileBase groundTile;
    public TileBase ceilingTile;
    public TileBase backgroundTile;
    public TileBase wallTile;

    public int sceneHeight;
    public int sceneWidth;
    
    //parametres du sol
    public int ground_height;
    public int ground_width;
    public Vector3Int ground_position;
    
    //parametres du plafond
    public int ceiling_height;
    public int ceiling_width;
    public Vector3Int ceiling_position;
    
    //parametres du background
    public int background_height;
    public int background_width;
    public Vector3Int background_position;

    public int wall_height, wall_width;

    //script d'entrainement
    public Training training;

    //prefabs
    public GameObject groundPrefab;
    public GameObject ceilingPrefab;
    public GameObject backgroundPrefab;
    public GameObject wallPrefab;

    public void placeTile(int x, int y, GameObject prefab)
{
    GameObject go = UnityEditor.PrefabUtility.InstantiatePrefab(prefab) as GameObject;
    go.transform.position = new Vector3(x, y, 0);
    go.transform.parent = training.transform;
    go.tag = "WFCReplaceable";
}
    public void placeMatrix(int height, int width, Vector3Int position, GameObject prefab)
    {
        for (int x = 0; x < width; x++){
            for (int y = 0; y < height; y++){
                placeTile(position.x + x, position.y + y, prefab);
            }
        }
    }

    public void placeGround(int height, int width)
    {
        placeMatrix(height, width, ground_position, groundPrefab);
    }
    public void placeCeiling(int height, int width)
    {
        placeMatrix(height, width, ceiling_position, ceilingPrefab);
    }
    public void placeBackground(int height, int width)
    {
        placeMatrix(height, width, background_position, backgroundPrefab);
    }
    public void placeWall(int height, int width)
    {
        placeMatrix(height, width, new Vector3Int(0, 1, 0), wallPrefab);
        placeMatrix(height, width, new Vector3Int(29, 1, 0), wallPrefab);
    }

    public void Start()// fonction quand on lance le mode game
    {
        placeBackground(background_height, background_width);
        placeCeiling(ceiling_height, ceiling_width);
        placeGround(ground_height, ground_width);
    }
    /*public void createEnvironment()
    {
        //1ere etage
        placeTile(4,1,groundPrefab);
        placeMatrix(2,1,new Vector3Int(5,1,0),groundPrefab);
        placeMatrix(3,1,new Vector3Int(6,1,0),groundPrefab);
        placeMatrix(4,3,new Vector3Int(7,1,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(13,4,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(18,4,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(23,4,0),groundPrefab);
        placeMatrix(1,3,new Vector3Int(15,2,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(27,4,0),groundPrefab);

        placeMatrix(2,1,new Vector3Int(28,5,0),groundPrefab);
        placeMatrix(2,2,new Vector3Int(25,7,0),groundPrefab);
        placeMatrix(6,1,new Vector3Int(18,8,0),groundPrefab);
        placeMatrix(4,1,new Vector3Int(19,8,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(20,8,0),groundPrefab);
        placeMatrix(1,2,new Vector3Int(22,12,0),groundPrefab);
        placeMatrix(2,1,new Vector3Int(23,13,0),groundPrefab);
        placeMatrix(1,4,new Vector3Int(14,13,0),groundPrefab);
        placeMatrix(1,5,new Vector3Int(7,14,0),groundPrefab);
        placeMatrix(1,3,new Vector3Int(2,15,0),groundPrefab);
        placeMatrix(2,1,new Vector3Int(2,16,0),groundPrefab);
    }*/

    public void createEnvironment()
{
    placeBackground(background_height, background_width);
    // === SOL continu ===
    placeMatrix(1, 40, new Vector3Int(0, 0, 0), groundPrefab);

    // === ESCALIERS GAUCHE ===
    placeTile(1, 2, groundPrefab); placeTile(2, 3, groundPrefab);
    placeTile(3, 4, groundPrefab); placeTile(4, 5, groundPrefab);

    // === ESCALIERS CENTRE-GAUCHE (MANQUAIENT) ===
    placeTile(12, 2, groundPrefab); placeTile(13, 3, groundPrefab);
    placeTile(14, 4, groundPrefab);

    // === ESCALIERS CENTRE-DROIT (MANQUAIENT) ===
    placeTile(24, 4, groundPrefab); placeTile(25, 3, groundPrefab);
    placeTile(26, 2, groundPrefab);

    // === ESCALIERS DROIT ===
    placeTile(36, 5, groundPrefab); placeTile(37, 4, groundPrefab);
    placeTile(38, 3, groundPrefab); placeTile(39, 2, groundPrefab);

    // === TUILES SEULES — pattern "surplomb isolé" (MANQUAIENT) ===
    placeTile(6,  5,  groundPrefab);
    placeTile(10, 8,  groundPrefab);
    placeMatrix(2,1,new Vector3Int(30, 7,0),  groundPrefab);
    placeTile(34, 4,  groundPrefab);

    // === PLATEFORMES COURTES (2 tuiles) — espacées d'au moins 3 ===
    placeMatrix(1, 2, new Vector3Int(7,  4,  0), groundPrefab);
    placeMatrix(1, 2, new Vector3Int(15, 7,  0), groundPrefab);
    placeMatrix(1, 2, new Vector3Int(20, 4,  0), groundPrefab);
    placeMatrix(1, 2, new Vector3Int(28, 9,  0), groundPrefab);
    placeMatrix(1, 2, new Vector3Int(33, 6,  0), groundPrefab);

    // === PLATEFORMES MOYENNES (3-4 tuiles) ===
    placeMatrix(1, 3, new Vector3Int(5,  9,  0), groundPrefab);
    placeMatrix(1, 4, new Vector3Int(9,  5,  0), groundPrefab);
    placeMatrix(1, 3, new Vector3Int(17, 11, 0), groundPrefab);
    placeMatrix(1, 4, new Vector3Int(23, 7,  0), groundPrefab);
    placeMatrix(1, 3, new Vector3Int(31, 5,  0), groundPrefab);
    placeMatrix(1, 4, new Vector3Int(35, 9,  0), groundPrefab);
    placeMatrix(1, 5, new Vector3Int(7, 16,  0), groundPrefab);
    placeMatrix(1, 4, new Vector3Int(33, 15,  0), groundPrefab);

    // === PLATEFORMES LARGES (5-6 tuiles) ===
    placeMatrix(1, 5, new Vector3Int(2,  12, 0), groundPrefab);
    placeMatrix(1, 6, new Vector3Int(14, 14, 0), groundPrefab);
    placeMatrix(1, 5, new Vector3Int(27, 12, 0), groundPrefab);

    // === COLONNES VERTICALES fines 1×3 (MANQUAIENT) ===
    placeMatrix(3, 1, new Vector3Int(8,  1, 0), groundPrefab);
    placeMatrix(3, 1, new Vector3Int(21, 1, 0), groundPrefab);
    placeMatrix(3, 1, new Vector3Int(32, 1, 0), groundPrefab);

    // === EMPILEMENTS — séparés les uns des autres ===
    placeMatrix(2, 2, new Vector3Int(11, 6,  0), groundPrefab);
    placeMatrix(2, 3, new Vector3Int(29, 4,  0), groundPrefab);
}

    private void OnValidate()
{
    UnityEditor.EditorApplication.delayCall += () =>
    {
        if (training != null){
            for (int i = training.transform.childCount - 1; i >= 0; i--){
                DestroyImmediate(training.transform.GetChild(i).gameObject);
            }
        }
        //placeWall(wall_height, wall_width);
        //placeBackground(background_height, background_width);
        //placeCeiling(ceiling_height, ceiling_width);
        //placeGround(ground_height, ground_width);
        createEnvironment();
    };
}
}