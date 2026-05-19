extends Node2D

@export var heart1: Texture2D
@export var heart0: Texture2D

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

func _ready():
	HealthManager.on_health_changed.connect(on_player_health_changed)

func on_player_health_changed(player_current_health: int):
	for i in range(hearts.size()):
		hearts[i].texture = heart1 if i < player_current_health else heart0
