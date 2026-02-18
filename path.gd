extends Node2D


var path: Array[Sprite2D]


func spawn_path(point_path: Array):
	for i in range(1, point_path.size()):
		var sprite := Sprite2D.new()
		sprite.texture = load("res://glow.png")
		sprite.position = point_path[i]
		sprite.apply_scale(Vector2(0.1, 0.1))
		add_child(sprite)
		path.append(sprite)
		

func destroy_step():
	var sprite = path.pop_front()
	if sprite:
		sprite.queue_free()


func destroy_path():
	for sprite in path:
		sprite.queue_free()
	path.clear()


func clear_path():
	for i in range(1, path.size()):
		path[i].queue_free()

	# Keep only the first element
	if path.size() > 0:
		path = [path[0]]
