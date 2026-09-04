## Gatilho de evento de mundo (GDD seção 6/9.2/9.6): uma Area2D simples
## posicionada na cena da ilha, do mesmo jeito que os SpawnPoint do Totem são
## Marker2D hoje. Dispara quando o jogador entra na área E a condição de
## estado/favor bate.
##
## Eventos ligados à passagem de tempo (não a um lugar), como uma emboscada
## espontânea ou um recrutador aparecendo, não usam este node — eles devem
## assinar WorldState diretamente ou o wave_started do Totem, que já funciona
## como a unidade de "ciclo" do jogo (seção 9.6).
extends Area2D

## Qual ilha este gatilho pertence.
@export var island_id: StringName = &""
## Estado mínimo pra o evento poder disparar. Deixe em &"" pra ignorar essa
## condição (ver WorldState.STATE_*).
@export var required_state: StringName = &""
## Facção cujo favor mínimo é exigido. Deixe em &"" pra ignorar essa condição.
@export var required_faction_id: StringName = &""
@export var required_favor_minimum: int = 0
## Se true, dispara só uma vez por sessão (a maioria dos eventos da seção 6
## deveria usar isso — ex: a execução pública agendada não repete).
@export var trigger_once: bool = true

## A cena escuta isto pra tocar a cutscene/diálogo/spawn correspondente.
signal event_triggered

var _has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if trigger_once and _has_triggered:
		return
	if not (body is Player):
		return
	if not _condition_met():
		return
	_has_triggered = true
	event_triggered.emit()

func _condition_met() -> bool:
	if required_state != &"" and WorldState.get_state(island_id) != required_state:
		return false
	if required_faction_id != &"" and WorldState.get_favor(island_id, required_faction_id) < required_favor_minimum:
		return false
	return true
