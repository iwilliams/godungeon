tool
extends Spatial

export(Resource) var dungeon_tiles setget _set_dungeon_tiles
func _set_dungeon_tiles(value):
    if Engine.editor_hint:
        if is_instance_valid(dungeon_tiles) and dungeon_tiles.is_connected("tiles_changed", self, "_draw_tiles"):
            dungeon_tiles.disconnect("tiles_changed", self, "_draw_tiles")
        if is_instance_valid(value) and not value.is_connected("tiles_changed", self, "_draw_tiles"):
            value.connect("tiles_changed", self, "_draw_tiles", [], CONNECT_DEFERRED)
    var should_draw_tiles = dungeon_tiles != value
    dungeon_tiles = value
    if should_draw_tiles:
        _draw_tiles()


export(int) var tile_size = 4

export(Dictionary) var tile_templates = {}
export(Array, Resource) var materials = []

export(bool) var show_nodes_in_editor = false setget _set_show_nodes_in_editor
func _set_show_nodes_in_editor(value: bool):
    show_nodes_in_editor = value
    _draw_tiles()


var tile_container


func _ready():
    tile_container = Spatial.new()
    add_child(tile_container)
    last_tile_coord = position_to_tile_coord(global_transform.origin)
    _draw_tiles()


func _on_visibility_changed():
    if visible:
        _draw_tiles()
    else:
        _clear_tiles()


func _clear_tiles():
    if is_instance_valid(tile_container):
        for child in tile_container.get_children():
            child.queue_free()


var last_tile_coord
func _physics_process(delta):
    var current_tile_coord = position_to_tile_coord(global_transform.origin)
    if last_tile_coord == null or last_tile_coord != current_tile_coord:
        last_tile_coord = current_tile_coord
        if materials.size() > 0:
            var rect: Rect2 = dungeon_tiles.get_rect()
            for material in materials:
                (material as ShaderMaterial).set_shader_param('tiles_offset', last_tile_coord + rect.position)


func _draw_tiles():
    if not is_inside_tree():
        return
        
    _clear_tiles()
    
    if not is_instance_valid(dungeon_tiles) or not is_instance_valid(tile_container):
        return
    
    tile_container.set_owner(get_tree().edited_scene_root if show_nodes_in_editor else null)
    
    var dt := dungeon_tiles as GodungeonTiles
    for tile_coord in dt.tiles.keys():
        var tile = dt.tiles.get(tile_coord)
        var tile_template := tile_templates.get(tile) as PackedScene
        if tile_template:
            var tile_instance = tile_template.instance()
            tile_instance.adjacency_map = dt.get_adjacency_map(tile_coord)
            tile_container.add_child(tile_instance)
            tile_instance.set_owner(get_tree().edited_scene_root if show_nodes_in_editor else null)
            tile_instance.transform.origin = Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size)
            
    if materials.size() > 0:
        var texture = dungeon_tiles.to_texture()
        var rect: Rect2 = dungeon_tiles.get_rect()
        for material in materials:
            (material as ShaderMaterial).set_shader_param('tiles_offset', last_tile_coord + rect.position)
            (material as ShaderMaterial).set_shader_param('tiles', texture)

    print("Draw tiles")


func position_to_tile_coord(position: Vector3):
    return Vector2(position.x / tile_size, position.z / tile_size).round()
    
    
func tile_coord_to_position(tile_coord: Vector2):
    return Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size).round()
