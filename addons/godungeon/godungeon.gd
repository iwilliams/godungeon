tool
extends EditorPlugin

const plugin_path := "res://addons/godungeon"

const dungeon_tile_resource_name := "GodungeonTile"
const dungeon_tile_resource_path := "%s/GodungeonTile.gd" % plugin_path

const dungeon_tiles_resource_name := "GodungeonTiles"
const dungeon_tiles_resource_path := "%s/GodungeonTiles.gd" % plugin_path

const dungeon_tile_color_pair_resource_name := "GodungeonTileColorPair"
const dungeon_tile_color_pair_resource_path:= "%s/%s.gd" % [plugin_path, dungeon_tile_color_pair_resource_name]

const dungeon_tiles_3d_resource_name := "GodungeonTiles3D"
const dungeon_tiles_3d_resource_path = "%s/%s.gd" % [plugin_path, dungeon_tiles_3d_resource_name]

const godungeon_tiles_resource_inspector_path = "%s/inspector_plugin/godungeon_tiles_resource_inspector.gd" % plugin_path

var dungeon_tiles_resource_inspector

func _enter_tree():
    add_custom_type(dungeon_tile_resource_name, "Resource", preload(dungeon_tile_resource_path), null)
    add_custom_type(dungeon_tiles_resource_name, "Resource", preload(dungeon_tiles_resource_path), null)
    add_custom_type(dungeon_tile_color_pair_resource_name, "Resource", preload(dungeon_tile_color_pair_resource_path), null)
    add_custom_type(dungeon_tiles_3d_resource_name, "Spatial", preload(dungeon_tiles_3d_resource_path), null)
    
    dungeon_tiles_resource_inspector = preload(godungeon_tiles_resource_inspector_path).new()
    add_inspector_plugin(dungeon_tiles_resource_inspector)

func _exit_tree():
    remove_custom_type(dungeon_tiles_resource_name)
    remove_custom_type(dungeon_tiles_3d_resource_path)
    remove_inspector_plugin(dungeon_tiles_resource_inspector)



func _object_is_dungeon_tiles_resource(object: Object):
    return object is preload(dungeon_tiles_resource_path)
