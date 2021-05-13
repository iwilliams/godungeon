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
#    call_deferred("_draw_tiles")
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
    
    var cached_templates = {}
    var multimesh_cache = {}
    
    var dt := dungeon_tiles as GodungeonTiles
    var big_static_body = StaticBody.new()
    tile_container.add_child(big_static_body)
    for tile_coord in dt.tiles.keys():
        var tile = dt.tiles.get(tile_coord)
        var tile_template := tile_templates.get(tile) as PackedScene
        if tile_template:
            if not cached_templates.has(tile_template):
                cached_templates[tile_template] = tile_template.instance()
            var tile_instance = cached_templates.get(tile_template)
            
            if tile_instance.has_method("get_meshes"):
                var adjacency_map = dt.get_adjacency_map(tile_coord)
                var meshes = tile_instance.call("get_meshes", adjacency_map)
                for mesh_instance in meshes:
                    var mesh = mesh_instance[0]
                    var mesh_transform = mesh_instance[1]
                    mesh_transform.origin += Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size)
                    if multimesh_cache.has(mesh):
                        (multimesh_cache[mesh] as Array).push_front(mesh_transform)
                    else:
                        multimesh_cache[mesh] = [mesh_transform]

                
                if not Engine.editor_hint and tile_instance.has_method("get_collision"):
                    var collision = tile_instance.get_collision(adjacency_map)
                    if collision.size() > 0:
                        var static_body := StaticBody.new()
                        for colliders in collision:
                            var shape = colliders[0].duplicate()
                            shape.transform = colliders[1]
                            shape.transform.origin += Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size)
                            big_static_body.add_child(shape)
#                            static_body.add_child(shape)
#                        static_body.transform.origin = Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size)
#                        tile_container.add_child(static_body)
                        
            else:
                var tile_node = tile_instance.duplicate()
                if "adjacency_map" in tile_instance:
                    tile_node.adjacency_map = dt.get_adjacency_map(tile_coord)
                tile_container.add_child(tile_node)
                tile_node.set_owner(get_tree().edited_scene_root if show_nodes_in_editor else null)
                tile_node.transform.origin = Vector3(tile_coord.x * tile_size, 0, tile_coord.y * tile_size)

    
    for mesh in multimesh_cache.keys():
        var instances = multimesh_cache.get(mesh)
        var multi_mesh_instance := MultiMeshInstance.new()
        tile_container.add_child(multi_mesh_instance)
        # Create the multimesh.
        var multimesh = MultiMesh.new()
        # Set the format first.
        multimesh.transform_format = MultiMesh.TRANSFORM_3D
        multimesh.color_format = MultiMesh.COLOR_NONE
        multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
        # Then resize (otherwise, changing the format is not allowed).
        multimesh.instance_count = instances.size()
        multimesh.mesh = mesh
        for index in range(0, instances.size()):
            multimesh.set_instance_transform(index, instances[index])
            
        multi_mesh_instance.set_multimesh(multimesh)
    
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
