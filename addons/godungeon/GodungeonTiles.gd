tool
extends Resource
class_name GodungeonTiles

signal tiles_changed

export var tiles := {} setget _set_tiles
func _set_tiles(value):
    tiles = value
    emit_signal("tiles_changed")

export(Dictionary) var tile_palette = {}


func _init():
    tiles = {}

func set_tile(coord: Vector2, tile_type):
    tiles[coord] = tile_type
    
    
func get_tile(coord: Vector2) -> GodungeonTile:
    var has_tile = tiles.has(coord)
    return tiles.get(coord)


func get_used_coords() -> Array:
    return tiles.keys().duplicate()


func get_adjacency_map(coord: Vector2) -> AdjacencyMap:
    var adjacency_map = AdjacencyMap.new()
    adjacency_map.COORD_M = coord

    adjacency_map.NW = get_tile(adjacency_map.COORD_NW)
    adjacency_map.N  = get_tile(adjacency_map.COORD_N)
    adjacency_map.NE = get_tile(adjacency_map.COORD_NE)

    adjacency_map.W  = get_tile(adjacency_map.COORD_W)
    adjacency_map.M  = get_tile(coord)
    adjacency_map.E  = get_tile(adjacency_map.COORD_E)

    adjacency_map.SW = get_tile(adjacency_map.COORD_SW)
    adjacency_map.S  = get_tile(adjacency_map.COORD_S)
    adjacency_map.SE = get_tile(adjacency_map.COORD_SE)

    return adjacency_map


func clear_tiles():
    _set_tiles({})

func flip_x():
    var new_tiles = {}
    for coord in tiles.keys():
        var new_coord = coord * Vector2(-1, 1)
        new_tiles[new_coord] = tiles[coord]
    _set_tiles(new_tiles)


func flip_y():
    var new_tiles = {}
    for coord in tiles.keys():
        var new_coord = coord * Vector2(1, -1)
        new_tiles[new_coord] = tiles[coord]
    _set_tiles(new_tiles)
    

func rotate_right():
    var new_tiles = {}
    for coord in tiles.keys():
        new_tiles[Vector2(coord.y, coord.x)] = tiles[coord]
    tiles = new_tiles
    flip_x()


func rotate_left() -> void:
    var new_tiles := {}
    for coord in tiles.keys():
        new_tiles[Vector2(coord.y, coord.x)] = tiles[coord]
    tiles = new_tiles
    flip_y()


func offset(offset_amount: Vector2) -> void:
    var new_tiles := {}
    for key in tiles.keys():
        var coord := key as Vector2
        new_tiles[coord + offset_amount] = get_tile(coord)
    _set_tiles(new_tiles)


func center() -> void:
    var rect := get_rect()
    offset(rect.position * Vector2(-1, -1))
    rect = get_rect()
    offset((rect.size * -.5).floor())


func get_rect() -> Rect2:
    if tiles.size() == 0:
        return Rect2(Vector2.ZERO, Vector2.ZERO)
    
    var top_left := tiles.keys()[0] as Vector2
    var bottom_right := tiles.keys()[0] as Vector2
        
    for key in tiles.keys():
        var coord := key as Vector2       
        if coord.x < top_left.x:
            top_left.x = coord.x

        if coord.y < top_left.y:
            top_left.y = coord.y
            
        if coord.x > bottom_right.x:
            bottom_right.x = coord.x
            
        if coord.y > bottom_right.y:
            bottom_right.y = coord.y
    
    var image_size = Vector2(bottom_right.x - top_left.x, bottom_right.y - top_left.y)
    
    return Rect2(top_left, image_size)
    

func to_image() -> Image:
    var rect := get_rect()
    var top_left = rect.position
    var bottom_right = rect.end
    var image_size = rect.size
            
    var tile_to_color = {}
    for color in tile_palette.keys():
        tile_to_color[tile_palette.get(color)] = color
    
    var image = Image.new()
    image.create(image_size.x + 1, image_size.y + 1, false, Image.FORMAT_RGBA8)
    image.lock()
    for coord in tiles.keys():
        var tile_type = get_tile(coord)
        var color = tile_to_color.get(tile_type)
        var pixel = coord + top_left.abs()
        image.set_pixel(pixel.x, pixel.y, color)
    image.unlock()
    return image


func to_texture() -> ImageTexture:
    var texture = ImageTexture.new()
    texture.create_from_image(to_image(), 0)
    return texture


func get_tiles_in_rect(rect: Rect2) -> GodungeonTiles:
    var rect_tiles = duplicate()
    rect_tiles.clear_tiles()
    for y in range(rect.position.y, rect.position.y + rect.size.y):
        for x in range(rect.position.x, rect.position.x + rect.size.x):
            var coord = Vector2(x, y)
            if tiles.has(coord):
                rect_tiles.set_tile(coord, get_tile(coord))
    return rect_tiles


func fill_tiles_in_rect(rect: Rect2, type: Object, fill_mask = []) -> void:
  for y in range(rect.position.y, rect.position.y + rect.size.y):
    for x in range(rect.position.x, rect.position.x + rect.size.x):
        var coord = Vector2(x, y)
        if fill_mask.size() == 0 or fill_mask.has(type):
            set_tile(coord, type)
            

func get_tile_type_coords(type: GodungeonTile, possible_coords: Array = get_used_coords()) -> Array:
    var type_coords := []
    for coord in possible_coords:
        if get_tile(coord) == type:
            type_coords.push_back(coord)
    return type_coords

            
func get_random_tile_type_coord(type: GodungeonTile, possible_coords: Array = get_used_coords()):
    var coord = null
    if possible_coords.size() == 0:
        return coord
        
    possible_coords.shuffle()
    coord = possible_coords.pop_front()
    while get_tile(coord) != type and possible_coords.size() > 0:
        coord = possible_coords.pop_front()
    return coord
    
    
func copy_from(other_tiles: GodungeonTiles) -> void:
    for coord in other_tiles.tiles.keys():
        set_tile(coord, other_tiles.get_tile(coord))
