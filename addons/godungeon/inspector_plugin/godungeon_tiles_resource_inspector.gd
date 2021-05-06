tool
extends EditorInspectorPlugin

const plugin_path := "res://addons/godungeon"
const dungeon_tiles_resource_name := "GodungeonTiles"
const dungeon_tiles_resource_path := "%s/%s.gd" % [plugin_path, dungeon_tiles_resource_name]

const dungeon_tiles_image_importer_path = "%s/inspector_plugin/DungeonTilesImageImporter.tscn" % plugin_path


func can_handle(object):
    if object is preload(dungeon_tiles_resource_path):
        return true
    else:
        return false


func parse_begin(object):
    var image_importer = preload(dungeon_tiles_image_importer_path).instance()
    image_importer.dungeon_tiles = object
    add_custom_control(image_importer)
