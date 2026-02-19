class_name Player extends CharacterBody2D

signal reached_step
signal check_collectables

@onready var game_manager: GameManager = %GameManager
@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

const MOVE_SPEED := 200.0

var grid_path: Array[Vector2]
var world_path: PackedVector2Array
var curr_path_index: int
var target_position: Vector2
var is_moving: bool = false


func _physics_process(delta: float) -> void:
	if grid_path.is_empty():
		animation_state.travel("idle")
		return

	if not is_moving:
		target_position = world_path[curr_path_index]
		is_moving = true
	
	var dir := target_position.x - global_position.x
	if dir != 0:
		player_sprite.flip_h = dir < 0
		
	animation_state.travel("run")

	move_towards_target(delta)


func move_towards_target(delta: float) -> void:
	global_position = global_position.move_toward(target_position, MOVE_SPEED * delta)

	if global_position == target_position:
		curr_path_index += 1
		var current_cell = grid_path.pop_front()
		reached_step.emit()

		if not grid_path.is_empty():
			target_position = world_path[curr_path_index]
		else:
			check_collectables.emit(current_cell)
			is_moving = false
