''## Npc1, a Cobrador de Impostos (GDD seção 2) — primeiro NPC político
## implementado, serve de exemplo pra validar o padrão de PoliticalNPC antes
## de replicar pros outros seis (Ysolda, Doren, Mãe Ivet, Aldric, Kessa, Bram).
##
## Reação (seção 2): com Coroa alta, relaxa e passa dicas de rota de
## patrulha. Com Rebeldes alta, some do posto por dias (ameaçada) e reaparece
## escoltada. Em Revolta, é substituída por um cobrador militarizado — o
## cargo continua existindo, a pessoa não.
##
## Falta anexar isto a uma cena de verdade (StaticBody2D + Interactable +
## Sprite2D, igual ao padrão de systems/totem/totem.tscn) assim que a arte
## dela existir. O texto de diálogo abaixo é placeholder — troque pelo
## sistema de diálogo real quando ele existir; o que importa aqui é o
## padrão de reação, não a UI de texto.
extends PoliticalNPC

const DIALOGUE := {
	&"paz": "Mais um dia de cobrança. Nada de especial.",
	&"tensao": "Andam falando mal da Coroa pelos becos. Melhor ter cuidado.",
	&"repressao": "As rotas de patrulha mudaram essa semana — vou te mostrar as mais seguras.",
	&"revolta": "[Escoltada por guardas armados — não quer conversar agora]",
}

var _current_line: String = DIALOGUE[&"paz"]

func _on_interact() -> void:
	print(_current_line)
	# TODO: plugar no sistema de diálogo de verdade quando ele existir.

func _apply_current_state(state: StringName) -> void:
	_current_line = DIALOGUE.get(state, DIALOGUE[&"paz"])
	# Em Revolução ela já não está mais no posto (seção 3.3 trata o colapso
	# geral); em Revolta especificamente ela "some por dias".
	visible = state != WorldState.STATE_REVOLTA and state != WorldState.STATE_REVOLUCAO
	# TODO: em Revolta, o certo (seção 2) é trocar por uma versão dela COM
	# escolta em vez de simplesmente sumir — isso pede uma segunda cena/sprite
	# que ainda não existe. Por enquanto, some, que já é o comportamento
	# funcionalmente mais próximo com a arte atual.
