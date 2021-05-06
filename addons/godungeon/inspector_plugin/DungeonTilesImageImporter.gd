tool
extends Control

var dungeon_tiles: GodungeonTiles

var floor_color = Color.white
var wall_color = Color.black

var image_path_to_import
var image_import_offset: Vector2 = Vector2.ZERO

func _on_FileDialog_file_selected(path):
    if not is_instance_valid(dungeon_tiles):
        return
    image_path_to_import = path
    $VBoxContainer/VBoxContainer/HBoxContainer/Label.text = image_path_to_import
    $VBoxContainer/VBoxContainer/Button.disabled = false
    $VBoxContainer/VBoxContainer/HBoxContainer2/Button.disabled = false


func import_image(use_offset = false):
    var texture := load(image_path_to_import) as Texture
    var image := texture.get_data()
    image.lock()
    var image_size = image.get_size()
    var tiles = {} if not use_offset else dungeon_tiles.tiles
    var offset = (image_size / 2).floor()
    if use_offset:
        offset -= image_import_offset
    for x in image_size.x:
        for y in image_size.y:
            var coord := Vector2(x, y)
            var color := image.get_pixelv(Vector2(x, y))
            if color.a > 0:
                var tile_type = dungeon_tiles.tile_palette.get(color)
                tiles[coord - offset] = tile_type
    image.lock()
    dungeon_tiles.tiles = tiles


func _on_export_pressed():
    if not is_instance_valid(dungeon_tiles):
        return
    dungeon_tiles.to_image()


func _on_Button3_pressed():
    dungeon_tiles.flip_x()


func _on_flip_y_pressed():
    dungeon_tiles.flip_y()


func _on_rotate_pressed():
    dungeon_tiles.rotate_right()


func _on_rotate_left_pressed():
    dungeon_tiles.rotate_left()


func _on_import_offset_x_value_changed(value):
    image_import_offset.x = value
    
    
func _on_import_offset_y_value_changed(value):
    image_import_offset.y = value


func _on_clear_tiles_pressed():
    dungeon_tiles.clear_tiles()


func _on_center_pressed():
    dungeon_tiles.center()
