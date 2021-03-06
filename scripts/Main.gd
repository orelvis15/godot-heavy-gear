extends Node

onready var context_panel = $GUILayer/LowerLeftPanel/ContextContainer
onready var unit_info_panel = $GUILayer/UnitInfoPanel
onready var camera = $Camera
onready var world_map = $WorldMap

func _ready():
	## seed
	randomize()
	
	## set camera limits
	var map_rect = world_map.get_bounding_rect()
	camera.set_limit_rect(map_rect)
	
	## register Context Panel items
	context_panel.register("dev_spawn_unit", context_panel.get_node("SpawnUnit"))
	context_panel.register("dev_delete_unit", context_panel.get_node("DeleteUnit"))
	context_panel.register("activate_unit", context_panel.get_node("ActivateUnit"))
	context_panel.register("unit_actions", context_panel.get_node("UnitActions"))
	context_panel.register("move_unit", context_panel.get_node("MoveUnit"))
	context_panel.register("select_facing", context_panel.get_node("SelectFacing"))
	
	## load the initial context
	context_panel.activate("activate_unit")
	
	var help_dialog = $GUILayer/QuickHelp
	help_dialog.popup_centered()

## capture any input events related to map objects and forward them to the context_panel
func _unhandled_input(event):
	if event is InputEventMouse:
		## unit cell position events
		var mouse_pos = world_map.get_global_mouse_position()
		if world_map.point_on_map(mouse_pos):
			var cell_pos = world_map.get_grid_cell(mouse_pos)
			context_panel.unit_cell_input_event(world_map, cell_pos, event)
		
		## terrain hex events
		var hex_pos = world_map.get_terrain_hex(mouse_pos)
		var terrain = world_map.get_terrain_at_hex(hex_pos)
		if terrain:
			context_panel.terrain_input_event(world_map, hex_pos, terrain, event)
		
		## map marker events
		var map_markers = []
		for marker_obj in get_tree().get_nodes_in_group("map_markers"):
			if marker_obj.has_mouse:
				map_markers.push_back(marker_obj)
		if !map_markers.empty():
			context_panel.map_markers_input_event(world_map, map_markers, event)
			_update_unit_info_panel(map_markers, event)

func _update_unit_info_panel(map_markers, event):
	if event.is_action_pressed("click_select"):
		unit_info_panel.select_markers(map_markers)
	elif event is InputEventMouseMotion:
		unit_info_panel.hover_markers(map_markers)