using UnityEngine;
using UnityEngine.Tilemaps;
public class LevelGenerator : MonoBehaviour
{
    public Tilemap tilemap;
    public TileBase groundTile;
    public int ground_height;
    public int ground_width;

    public void placeGround(int height, int width)// sert à placer une ligne de sols
    {
        for (int x = 0; x < width; x++){
            for(int y = 0; y < height; y++){
                tilemap.SetTile(
                    new Vector3Int(3*x, 3*y, 0),
                    groundTile
                );
            }
        }
    }
    public void Start()// fonction quand on lance le mode game
    {
        placeGround(ground_height,ground_width);
    }
    private void OnValidate()//genere quand on change une donnée
    {
        tilemap.ClearAllTiles();
        placeGround(ground_height,ground_width);
    }
}
