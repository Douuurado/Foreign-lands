## Label de depuração do PROTOTYPE — não é UI final (a seção 5/6 do GDD tratam
## a consequência visual de verdade, e a UI do jogo vive em ui/game_screen).
## Serve só pra ver os números de favor/pressão/estado mudando em tempo real
## enquanto se testa a sequência escolha -> WorldState -> Totem/NPC/visual,
## sem precisar abrir o painel de output do editor. Trocar por UI de verdade
## quando ela existir — ver PROXIMOS-PASSOS.md.
extends Label

@export var island_id: StringName = &"vaelmoor"

func _ready() -> void:
	WorldState.favor_changed.connect(_on_favor_changed)
	WorldState.state_changed.connect(_on_state_changed)
	_refresh()

func _on_favor_changed(_changed_island: StringName, _faction_id: StringName, _new_value: int) -> void:
	_refresh()

func _on_state_changed(_changed_island: StringName, _old_state: StringName, _new_state: StringName) -> void:
	_refresh()

func _refresh() -> void:
	var definition := WorldState.get_definition(island_id)
	var data := WorldState.get_island_data(island_id)
	if definition == null or data == null:
		return
	var lines := PackedStringArray()
	lines.append("Ilha: %s — estado: %s" % [definition.display_name, data.current_state])
	for faction_id in definition.faction_ids:
		lines.append("%s: %d" % [faction_id, data.faction_favor.get(faction_id, 0)])
	lines.append("pressão latente: %d" % data.latent_pressure)
	text = "\n".join(lines)
