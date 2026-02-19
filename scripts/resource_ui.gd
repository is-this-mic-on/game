class_name ResourceUI extends Control


@onready var game_manager: GameManager = %GameManager
@onready var gold_text: Label = $PanelContainer/MarginContainer/HBoxContainer/GoldHBox/GoldText


func _ready() -> void:
	game_manager.gained_gold.connect(update_gold_display)


func update_gold_display() -> void:
	gold_text.text = str(game_manager.gold_count)
