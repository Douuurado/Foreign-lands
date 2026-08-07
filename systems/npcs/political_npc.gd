## Classe-base pros sete NPCs políticos do GDD (seção 2) — centraliza a
## leitura comum do WorldState pra não repetir a mesma lógica em sete
## scripts diferentes. Mesmo espírito do GunDemo como base pras armas
## (systems/weapons/gun_demo.gd).
##
## Continua sendo um CharacterBody2D/StaticBody2D com um Interactable filho —
## exatamente o padrão de interação que o Totem já usa. Não reinventa nada,
## só reage.
##
## Um NPC concreto (ex: Renata, em scenes/npcs/renata/) estende esta classe e
## sobrescreve _on_interact e _apply_current_state. Ver renata.gd como
## exemplo de referência antes de replicar pros outros seis.
class_name PoliticalNPC extends StaticBody2D

## Qual ilha este NPC pertence — deve bater com o island_id do Totem/WorldState
## dessa mesma cena.
@export var island_id: StringName = &""

@onready var interactable: Area2D = $Interactable

func _ready() -> void:
	interactable.interact = _on_interact
	WorldState.favor_changed.connect(_on_favor_changed)
	WorldState.state_changed.connect(_on_state_changed)
	# Aplica o estado atual assim que o NPC entra na cena — cobre o caso de
	# a cena carregar direto num estado que não é Paz (ex: depois de um load).
	_apply_current_state(WorldState.get_state(island_id))

## Sobrescreva no NPC concreto: o que acontece quando o jogador interage.
func _on_interact() -> void:
	pass

## Reage a QUALQUER mudança de favor nesta ilha. Sobrescreva só se o NPC
## precisar de granularidade maior que "mudou de estado" — ex: Doren revelando
## o estoque liberado exatamente quando rebel_favor cruza 35, um limiar que
## não corresponde a nenhuma transição de estado da seção 8.
func _on_favor_changed(changed_island: StringName, _faction_id: StringName, _new_value: int) -> void:
	if changed_island != island_id:
		return

## Chamado automaticamente quando o estado calculado da ilha muda (seção 8).
func _on_state_changed(changed_island: StringName, _old_state: StringName, new_state: StringName) -> void:
	if changed_island != island_id:
		return
	_apply_current_state(new_state)

## Sobrescreva: decide aparência/diálogo/comportamento pro estado dado.
## Chamado tanto em _ready() (carregar já num estado avançado) quanto toda
## vez que o estado muda durante a sessão.
func _apply_current_state(_state: StringName) -> void:
	pass
