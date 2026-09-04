## Ponto de escolha política mínimo (GDD seção 4) — versão prototípica de uma
## "missão": ao interagir, aplica direto os deltas de reputação da tabela 4.2
## via WorldState.apply_reputation. Não substitui as 8 missões reais da
## seção 7 (que têm combate/furtividade de verdade acontecendo) — é o jeito
## mais barato de provar que "escolha -> WorldState -> Totem/NPC/visual reage"
## funciona de ponta a ponta dentro da própria arena, sem esperar as missões
## existirem.
##
## Repetível de propósito (ao contrário de uma missão real, que só paga uma
## vez): isso deixa testar a curva inteira Paz -> Tensão -> Repressão/Revolta
## só ficando parado apertando "interagir", sem precisar montar as 8 missões
## primeiro. Quando as missões da seção 7 existirem, elas chamam
## WorldState.apply_reputation direto (do resultado da própria jogabilidade,
## não de um menu) e este node pode virar só decoração de cenário ou sair de
## cena — ver PROXIMOS-PASSOS.md.
class_name PoliticalChoice extends StaticBody2D

@export var island_id: StringName = &"vaelmoor"
@export var choice_label: String = ""
## Deltas no mesmo formato da tabela 4.2 do GDD, ex: {&"coroa": 12}.
@export var favor_deltas: Dictionary = {}
## Segundos de bloqueio depois de cada uso, só pra não contar dois cliques
## do mesmo toque de botão como duas escolhas.
@export var cooldown: float = 0.4

@onready var interactable: Area2D = $Interactable

var _on_cooldown: bool = false

func _ready() -> void:
	interactable.interact_name = choice_label
	interactable.interact = _on_interact

func _on_interact() -> void:
	if _on_cooldown:
		return
	_on_cooldown = true
	WorldState.apply_reputation(island_id, favor_deltas)
	print("%s -> %s" % [choice_label, favor_deltas])
	await get_tree().create_timer(cooldown).timeout
	_on_cooldown = false
