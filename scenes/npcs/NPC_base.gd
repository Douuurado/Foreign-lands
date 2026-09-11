class_name NPCBase
extends CharacterBody2D

@export_category("Informações do NPC")
@export var npc_name: String = "NPC"
@export_multiline var dialogue: Array[String] = []



@export_category("Configurações")
@export var can_interact: bool = true
var player_dentro := false

func _process(_delta):
	if player_dentro and Input.is_action_just_pressed("interagir"):
		conversar()

func conversar():
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
		player_dentro = true
		print("Player entrou no raio de interação")


func _on_area_2d_area_exited(area: Area2D) -> void:
		player_dentro = false
		print("Player saiu do raio de interação")
