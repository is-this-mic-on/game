extends Node


signal gained_gold()


var gold_count: int = 0


func gain_gold(gold_gained) -> void:
	gold_count += gold_gained
	emit_signal("gained_gold")
