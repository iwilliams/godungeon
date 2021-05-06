tool
extends Resource
class_name AdjacencyMap

# +----+---+----+
# | NW | N | NE |
# +----+---+----+
# | W  | M |  E |
# +----+---+----+
# | SW | S | SE |
# +----+---+----+

const SIDE_NW = 1
const SIDE_N  = 1 << 1
const SIDE_NE = 1 << 2
const SIDE_W  = 1 << 3
const SIDE_M  = 1 << 4
const SIDE_E  = 1 << 5
const SIDE_SW = 1 << 6
const SIDE_S  = 1 << 7
const SIDE_SE = 1 << 8

const SIDES = {
    "NW": SIDE_NW,
    "N" : SIDE_N,
    "NE": SIDE_NE,
    "W" : SIDE_W,
    "M" : SIDE_M,
    "E" : SIDE_E,
    "SW": SIDE_SW,
    "S" : SIDE_S,
    "SE": SIDE_SE  
}

var adjacent := {}

export(Resource) var NW setget _set_nw, _get_nw
func _set_nw(value):
    adjacent[SIDE_NW] = value
func _get_nw():
    return adjacent.get(SIDE_NW)


export(Resource) var N setget _set_n, _get_n
func _set_n(value):
    adjacent[SIDE_N] = value
func _get_n():
    return adjacent.get(SIDE_N)


export(Resource) var NE setget _set_ne, _get_ne
func _set_ne(value):
    adjacent[SIDE_NE] = value
func _get_ne():
    return adjacent.get(SIDE_NE)
    

export(Resource) var W setget _set_w, _get_w
func _set_w(value):
    adjacent[SIDE_W] = value
func _get_w():
    return adjacent.get(SIDE_W)


export(Resource) var M setget _set_m, _get_m
func _set_m(value):
    adjacent[SIDE_M] = value
func _get_m():
    return adjacent.get(SIDE_M)


export(Resource) var E setget _set_e, _get_e
func _set_e(value):
    adjacent[SIDE_E] = value
func _get_e():
    return adjacent.get(SIDE_E)


export(Resource) var SW setget _set_sw, _get_sw
func _set_sw(value):
    adjacent[SIDE_SW] = value
func _get_sw():
    return adjacent.get(SIDE_SW)


export(Resource) var S setget _set_s, _get_s
func _set_s(value):
    adjacent[SIDE_S] = value
func _get_s():
    return adjacent.get(SIDE_S)


export(Resource) var SE setget _set_se, _get_se
func _set_se(value):
    adjacent[SIDE_SE] = value
func _get_se():
    return adjacent.get(SIDE_SE)
