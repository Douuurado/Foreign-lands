extends Node2D

## Textura do coração cheio/ativo.
@export var heart1: Texture2D
## Textura do coração vazio/inativo.
@export var heart0: Texture2D

## Lista contendo as referências para os três nós de sprite/textura de coração na UI.
@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3
]

## Conecta este elemento de interface ao sinal global de alteração de vida do jogador.
func _ready():
	HealthManager.on_health_changed.connect(on_player_health_changed)

## Atualiza visualmente os sprites de coração sempre que a vida do jogador muda.
func on_player_health_changed(player_current_health: int):
	# Percorre todos os corações da lista e altera a textura com base no índice
	for i in range(hearts.size()):
		# Se o índice do coração for menor que a vida atual do player, ele fica cheio; caso contrário, vazio
		hearts[i].texture = heart1 if i < player_current_health else heart0
