class_name NPCBase
extends CharacterBody2D

# Exporta variaveis pra Base dos NPCs
@export_category("Informações do NPC")
@export var npc_name: String = "NPC"
@export_multiline var dialogue: Array[String] = []


@export_category("Configurações")
@export var can_interact: bool = true


var player_dentro := false
var indice_dialogo := 0

#Verifica se o player está dentro da area de interação do NPC
func _process(_delta):

	if not can_interact:
		return

	if player_dentro:
		conversar()

#faz o dialogo do NPC rodar
func conversar():

	# ==========================================
	# JÁ ESTÁ EM UM DIÁLOGO
	# ==========================================

	if DialogueManager.em_dialogo:

		# ESC fecha o diálogo
		if Input.is_action_just_pressed("ESC PRO NPC (MUDAR PARA MAIS TARDE)"):
			
			finalizar_dialogo()
			return

		# E passa para a próxima fala
		if Input.is_action_just_pressed("interact"):
			
			proxima_fala()
			return

		return


	# ==========================================
	# NÃO ESTÁ EM DIÁLOGO
	# ==========================================

	if Input.is_action_just_pressed("interact"):
		iniciar_dialogo()


func iniciar_dialogo():

	if dialogue.is_empty():
		print("ERRO: esse NPC não possui diálogos!")
		return

	DialogueManager.em_dialogo = true

	indice_dialogo = 0

	mostrar_fala()


func proxima_fala():

	

	indice_dialogo += 1

	# Chegou ao final
	if indice_dialogo >= dialogue.size():
		finalizar_dialogo()
		return

	mostrar_fala()


func mostrar_fala():

	print(npc_name + ": " + dialogue[indice_dialogo])


func finalizar_dialogo():

	DialogueManager.em_dialogo = false
	indice_dialogo = 0
	print("Fim do Diálogo")


# ==========================================
# INTERACTION AREA
# ==========================================

func _on_interaction_area_area_entered(area: Area2D) -> void:

	

	player_dentro = true

	


func _on_interaction_area_area_exited(area: Area2D) -> void:

	

	player_dentro = false

	if DialogueManager.em_dialogo:
		finalizar_dialogo()
