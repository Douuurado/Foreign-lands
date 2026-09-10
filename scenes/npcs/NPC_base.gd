class_name NPCBase
extends CharacterBody2D

@export_category("Informações do NPC")
@export var npc_name: String = "NPC"
@export_multiline var dialogue: Array[String] = []



@export_category("Configurações")
@export var can_interact: bool = true


func interact() -> void:
	if not can_interact:
		return
	elif Input.is_key_pressed(KEY_E):
		print(npc_name)
		print(dialogue)
	# Aqui você chama o seu sistema de diálogo.
	# Por enquanto, apenas mostra no console.
