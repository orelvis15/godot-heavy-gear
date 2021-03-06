extends Node2D

const Constants = preload("res://scripts/Constants.gd")
const HexUtils = preload("res://scripts/helpers/HexUtils.gd")

## dimensions of terrain hexes
## it is important that these are all multiples of 4, due to the geometry of hex grids
## also, note that for regular hexagons, w = sqrt(3)/2 * h
const TERRAIN_WIDTH  = 64*4 #256
const TERRAIN_HEIGHT = 74*4 #296

const UNITGRID_WIDTH = 16*4 #64
const UNITGRID_HEIGHT = 18*4 #72

const UNITGRID_SIZE = UNITGRID_WIDTH/HexUtils.UNIT_DISTANCE # grid spacing in distance units

var tileset_id = "default" #TODO

onready var terrain = $TerrainTiles
onready var unit_grid = $UnitGrid

func _ready():
	terrain.cell_size = Vector2(TERRAIN_WIDTH, TERRAIN_HEIGHT*3/4)
	unit_grid.cell_size = Vector2(UNITGRID_WIDTH, UNITGRID_HEIGHT*3/4)
	
	terrain.z_as_relative = false
	terrain.z_index = Constants.TERRAIN_ZLAYER

## returns the bounding rectangle in world coords
func get_bounding_rect():
	var cell_bounds = terrain.get_used_rect()
	var cell_size = terrain.cell_size
	var cell_to_pixel = Transform2D(Vector2(cell_size.x, 0), Vector2(0, cell_size.y), Vector2())
	return Rect2(cell_to_pixel * cell_bounds.position, cell_to_pixel * cell_bounds.size)


## Terrain Hexes

func get_terrain_hex(world_pos):
	return terrain.world_to_map(world_pos)

## returns the position of the hex centre
func get_terrain_pos(hex_pos):
	var hex_origin = terrain.map_to_world(hex_pos)
	return hex_origin + terrain.cell_size/2

func get_terrain_at(world_pos):
	var hex_pos = get_terrain_hex(world_pos)
	return get_terrain_at_hex(hex_pos)

func get_terrain_at_hex(hex_pos):
	var tile_idx = terrain.get_cellv(hex_pos)
	return TerrainTypes.get_terrain_info(tileset_id, tile_idx)

func point_on_map(world_pos):
	var hex_pos = get_terrain_hex(world_pos)
	var tile_id = terrain.get_cellv(hex_pos)
	return tile_id >= 0


## Unit Grid Cells

func get_grid_cell(world_pos):
	var cell_pos = unit_grid.world_to_map(world_pos)
	return cell_pos

## returns the position of the cell centre
func get_grid_pos(cell_pos):
	return unit_grid.map_to_world(cell_pos) + unit_grid.cell_size/2

func get_angle_to(cell_from, cell_to):
	var from_pos = get_grid_pos(cell_from)
	var to_pos = get_grid_pos(cell_to)
	return (to_pos - from_pos).angle()

## gets the closest direction to get from one cell to another
func get_dir_to(cell_from, cell_to):
	return HexUtils.nearest_dir(get_angle_to(cell_from, cell_to))

## returns the distance betwen the centres of two cells, in distance units
func grid_distance(cell1, cell2):
	var pos1 = get_grid_pos(cell1)
	var pos2 = get_grid_pos(cell2)
	var pixel_dist = (pos1 - pos2).length()
	return HexUtils.pixels2units(pixel_dist)

func path_distance(cell_path):
	var distance = 0
	var last_cell = null
	for next_cell in cell_path:
		if last_cell:
			distance += grid_distance(last_cell, next_cell)
		last_cell = next_cell
	return distance

func grid_cell_on_map(cell_pos):
	return point_on_map(get_grid_pos(cell_pos))

func get_neighbors(cell_pos):
	var neighbors = []
	for other_pos in HexUtils.get_neighbors(cell_pos).values():
		if grid_cell_on_map(other_pos):
			neighbors.push_back(other_pos)
	return neighbors


## Objects

func add_object(object, cell_pos):
	add_child(object)
	object.set_cell_position(cell_pos)

func get_objects_in_cells(grid_cells):
	var rval = {}
	for child in get_children():
		if child.has_method("get_cell_position"):
			var child_cell = child.get_cell_position()
			if grid_cells.has(child_cell):
				rval[child] = child_cell
	return rval

## return true if a unit can pass from a given cell into another
func unit_can_pass(unit, movement_mode, from_cell, to_cell):
	## check that to_cell is actually on the map
	var to_pos = get_grid_pos(to_cell)
	var from_pos = get_grid_pos(from_cell)
	var midpoint = 0.5*(to_pos + from_pos)
	if !point_on_map(to_pos) || !point_on_map(midpoint):
		return false
	
	## check that the terrain is passable
	var dest_info = get_terrain_at(to_pos)
	if dest_info.impassable.has(movement_mode.type_id):
		return false
	
	var midpoint_info = get_terrain_at(midpoint)
	if midpoint_info.impassable.has(movement_mode.type_id):
		return false
	
	## make sure there are no objects that could block us
	for object in get_objects_in_cells([ to_cell ]):
		if object != unit && !object.can_pass(unit):
			return false

	return true

## return true if a unit can stop (i.e. finish movement) in a given cell
func unit_can_place(unit, to_cell):
	## check that to_cell is actually on the map
	if !grid_cell_on_map(to_cell):
		return false
	
	## make sure there are no objects that could block us
	for object in get_objects_in_cells([ to_cell ]):
		if object != unit && !object.can_stack(unit):
			return false
	
	return true