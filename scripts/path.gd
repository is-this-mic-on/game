class_name Path extends Node2D


const path_sprite = preload("res://assets/glow.png")

var path: Array[Sprite2D]


func spawn_path(point_path: PackedVector2Array) -> void:
	for i in range(1, point_path.size()):
		var sprite := Sprite2D.new()
		sprite.texture = path_sprite
		sprite.position = point_path[i]
		sprite.apply_scale(Vector2(0.1, 0.1))
		add_child(sprite)
		path.append(sprite)
		

func destroy_step() -> void:
	var sprite = path.pop_front()
	if sprite:
		sprite.queue_free()


func destroy_path() -> void:
	for sprite in path:
		sprite.queue_free()
	path.clear()


func clear_path() -> void:
	for i in range(1, path.size()):
		path[i].queue_free()
	path = path.slice(0,1)
