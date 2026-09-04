## Consequência visual mínima da seção 5 do GDD — o jeito mais barato de fazer
## o jogador SENTIR a mudança de estado sem arte nova (sugestão técnica do
## próprio GDD, seção 5): escurece/tinge a paleta da cena conforme o estado
## calculado da ilha muda (WorldState.state_changed). Funciona com o renderer
## gl_compatibility que o projeto já usa.
##
## Isso cobre só o primeiro degrau do "Passo 4" (ver systems/world_state/README.md)
## — as consequências visuais completas da seção 5 (densidade de patrulha,
## pichações, bandeiras trocadas, fachadas queimadas) ainda pedem cenário e
## arte reais que não existem no prototype. Ver PROXIMOS-PASSOS.md.
extends CanvasModulate

@export var island_id: StringName = &"vaelmoor"
@export var tween_duration: float = 1.2

const STATE_COLORS := {
	&"paz": Color(1.0, 1.0, 1.0, 1.0),
	&"tensao": Color(1.0, 0.92, 0.75, 1.0),
	&"repressao": Color(0.75, 0.55, 0.55, 1.0),
	&"revolta": Color(0.85, 0.4, 0.3, 1.0),
	&"revolucao": Color(0.45, 0.15, 0.15, 1.0),
}

func _ready() -> void:
	color = STATE_COLORS.get(WorldState.get_state(island_id), Color.WHITE)
	WorldState.state_changed.connect(_on_state_changed)

func _on_state_changed(changed_island: StringName, _old_state: StringName, new_state: StringName) -> void:
	if changed_island != island_id:
		return
	var target: Color = STATE_COLORS.get(new_state, Color.WHITE)
	var tween := create_tween()
	tween.tween_property(self, "color", target, tween_duration)
