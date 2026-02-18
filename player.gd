extends CharacterBody2D

@onready var game_manager: Node = %GameManager
@onready var path_renderer: Node2D = $"../Path"
@onready var ground_map: TileMapLayer = $"../Ground"
@onready var environment_map: TileMapLayer = $"../Environment"
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

const MOVE_SPEED := 200.0
const TILE_SIZE := Vector2(64, 64)

var nav_grid: AStarGrid2D
var grid_path: Array[Vector2i]	# Used for player movement along the grid
var world_path: Array			# Used for spawning the sprites indicating path
var target_position: Vector2
var is_moving: bool = false


func _ready() -> void:
	setup_navigation_grid()


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
			var env_data := environment_map.get_cell_tile_data(cell)
			var has_ground := ground_map.get_cell_tile_data(cell) != null

			if not has_ground or env_data and env_data.get_custom_data("unwalkable"):
				nav_grid.set_point_solid(cell)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("move"):
		return
	elif is_moving:
		grid_path = [grid_path[0]]
		path_renderer.clear_path()
	else:
		path_renderer.destroy_path()
		
	var target_cell := ground_map.local_to_map(get_global_mouse_position())
	var start_cell := ground_map.local_to_map(target_position if is_moving else global_position)
	
	var point_path := Array(nav_grid.get_point_path(start_cell, target_cell))
	for i in point_path.size():
		point_path[i] += TILE_SIZE / 2
		
	path_renderer.spawn_path(point_path)
		
	if point_path == world_path:
		var id_path := nav_grid.get_id_path(start_cell, target_cell)
		if id_path.is_empty():
			return
		grid_path = id_path if is_moving else id_path.slice(1)
	else:
		world_path = point_path


func _physics_process(delta: float) -> void:
	if grid_path.is_empty():
		animation_state.travel("idle")
		return

	if not is_moving:
		target_position = ground_map.map_to_local(grid_path.front())
		is_moving = true
	
	if target_position.x - global_position.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif target_position.x - global_position.x > 0:
		$AnimatedSprite2D.flip_h = false
	animation_state.travel("run")

	move_towards_target(delta)


func move_towards_target(delta: float) -> void:
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)

	if global_position == target_position:
		grid_path.pop_front()
		path_renderer.destroy_step()

		if not grid_path.is_empty():
			target_position = ground_map.map_to_local(grid_path.front())
		else:
			is_moving = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("gold"):
		game_manager.gain_gold(1)
