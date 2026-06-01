using UnityEngine;
using UnityEngine.Tilemaps;
public class LevelGenerator : MonoBehaviour
{
    //parametres de la scene
    public Tilemap tilemap;
    public TileBase groundTile;
    public TileBase ceilingTile;
    public TileBase backgroundTile;
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

    public void placeTile(Vector3Int position, TileBase tileBase)
    {
        tilemap.SetTile(
                new Vector3Int(position.x, position.y, 0),
                tileBase
        );
    }
    public void placeTile(int x, int y, TileBase tileBase)
    {
        tilemap.SetTile(
                new Vector3Int(x, y, 0),
                tileBase
        );
    }
    public void placeMatrix(int height, int width, Vector3Int position, TileBase tileBase)// sert à placer une matrice de tuiles
    {
    for (int x = 0; x < width; x++){
        for (int y = 0; y < height; y++){
            placeTile(new Vector3Int(position.x+x,position.y+y,0),tileBase);
        }
    }
    }

    public void placeGround(int height, int width)// sert à placer une matrice de sols
    {
        placeMatrix(height,width,new Vector3Int(ground_position.x,ground_position.y,0),groundTile);
    }
    public void placeCeiling(int height, int width)// sert à placer une matrice de plafonds
    {
        placeMatrix(height,width,new Vector3Int(ceiling_position.x,ceiling_position.y,0),ceilingTile);
    }
    public void placeBackground(int height, int width)// sert à placer une matrice de backgrounds
    {
        placeMatrix(height,width,new Vector3Int(background_position.x, background_position.y, 0),backgroundTile);
    }

    public void Start()// fonction quand on lance le mode game
    {
        placeBackground(background_height,background_width);
        placeCeiling(ceiling_height,ceiling_width);
        placeGround(ground_height,ground_width);
        
    }
    private void OnValidate()//genere quand on change une donnée
    {
        tilemap.ClearAllTiles();
        placeBackground(background_height,background_width);
        placeCeiling(ceiling_height,ceiling_width);
        placeGround(ground_height,ground_width);

    }
}
