class_name Navigation extends Node2D


@onready var player: Player = $Player
@onready var path_renderer: Path = $Path
@onready var ground_map: TileMapLayer = $Ground
@onready var environment_map: TileMapLayer = $Environment
@onready var plateau_map: TileMapLayer = $Plateau

const TILE_SIZE := Vector2(64, 64)

var nav_grid: AStarGrid2D
var world_path: PackedVector2Array	# Used for spawning the sprites indicating path


func _ready() -> void:
	setup_navigation_grid()
	player.reached_step.connect(path_renderer.destroy_step)
	

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("move"):
		return
	elif player.is_moving:
		player.grid_path = [player.grid_path[0]]
		path_renderer.clear_path()
	else:
		path_renderer.destroy_path()
		
	var start_cell := ground_map.local_to_map(
		player.target_position if player.is_moving else player.global_position)
	var target_cell := ground_map.local_to_map(get_global_mouse_position())
	
	var point_path := get_point_path(start_cell, target_cell)
	path_renderer.spawn_path(point_path)
		
	if point_path == world_path:
		player.grid_path = get_grid_path(start_cell, target_cell)
	else:
		world_path = point_path


func setup_navigation_grid() -> void:
	nav_grid = AStarGrid2D.new()

	var used_rect := ground_map.get_used_rect()
	nav_grid.region = used_rect
	nav_grid.cell_size = TILE_SIZE
	nav_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	nav_grid.update()

	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			var cell := Vector2i(x, y)
			if tile_unwalkable(cell):
				nav_grid.set_point_solid(cell)

func tile_unwalkable(cell: Vector2i) -> bool:
	var env_data := environment_map.get_cell_tile_data(cell)
	var plateau_data := plateau_map.get_cell_tile_data(cell)
	var ground_data := ground_map.get_cell_tile_data(cell)
	
	var environment_unwalkable: bool = env_data and env_data.get_custom_data("unwalkable")
	var plateau_edge: bool = plateau_data and plateau_data.get_custom_data("unwalkable")
	
	return ground_data == null and plateau_data == null or environment_unwalkable or plateau_edge


func get_point_path(start_cell: Vector2, target_cell: Vector2) -> PackedVector2Array:
	var point_path := nav_grid.get_point_path(start_cell, target_cell)
	for i in point_path.size():
		point_path[i] += TILE_SIZE / 2
	return point_path


func get_grid_path(start_cell: Vector2, target_cell: Vector2) -> Array[Vector2]:
	var grid_path: Array[Vector2]
	var id_path := nav_grid.get_id_path(start_cell, target_cell)
	for i in range(not player.is_moving, id_path.size()):
		grid_path.append(ground_map.map_to_local(id_path[i]))
	return grid_path
