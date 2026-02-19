class_name GameManager extends Node

signal gained_gold

var gold_count: int = 0


func gain_gold(gold_gained: int) -> void:
	gold_count += gold_gained
	gained_gold.emit()
