using UnityEngine;
using UnityEngine.Tilemaps;
public class LevelGenerator : MonoBehaviour
{
    //parametres de la scene
    public Tilemap backgroundMap;
    public Tilemap environmentMap;

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
        placeMatrix(height, width, new Vector3Int(9, 1, 0), wallPrefab);
    }

    public void Start()// fonction quand on lance le mode game
    {
        placeBackground(background_height, background_width);
        placeCeiling(ceiling_height, ceiling_width);
        placeGround(ground_height, ground_width);
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
        placeBackground(background_height, background_width);
        placeWall(9, 1);
        placeCeiling(ceiling_height, ceiling_width);
        placeGround(ground_height, ground_width);
    };
}
}