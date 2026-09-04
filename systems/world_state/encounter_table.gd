## Lista de cenas de inimigo por estado da ilha (GDD seção 9.3) — a evolução
## natural do enemy_scene único que o totem.gd usava antes: em vez de uma
## cena fixa, uma tabela pequena indexada pelo estado atual.
##
## Os cinco estados são a "forma universal" que se repete em toda ilha
## (seção 10.2) — por isso os campos ficam fixos aqui (mais fácil de editar
## no Inspector pro time) em vez de um dicionário genérico.
##
## Cada campo aceita várias cenas porque a tabela da seção 3.2 mistura tipos
## de inimigo dentro do mesmo estado (ex: Repressão = hordas padrão +
## prisioneiros acorrentados). Deixe um campo vazio pra o Totem cair de volta
## pro enemy_scene padrão nesse estado (bom enquanto as variantes de inimigo
## ainda não existem).
class_name EncounterTable extends Resource

## Hordas padrão (o inimigo genérico atual). Baseline, nenhum twist.
@export var paz: Array[PackedScene] = []
## Hordas padrão + variante "provocador" (mais rápida, errática).
@export var tensao: Array[PackedScene] = []
## Hordas padrão + prisioneiros rebeldes acorrentados forçados à arena.
@export var repressao: Array[PackedScene] = []
## Simpatizantes sabotando o Totem + reforços reais enviados pra conter.
@export var revolta: Array[PackedScene] = []
## Os dois grupos acima brigando entre si e com o jogador.
@export var revolucao: Array[PackedScene] = []

## Devolve as cenas cadastradas pro estado atual. Se a lista estiver vazia
## (nenhuma variante cadastrada ainda pra esse estado), o Totem usa isso pra
## decidir se cai de volta pro enemy_scene padrão.
func get_scenes_for(state: StringName) -> Array[PackedScene]:
	match state:
		WorldState.STATE_TENSAO:
			return tensao
		WorldState.STATE_REPRESSAO:
			return repressao
		WorldState.STATE_REVOLTA:
			return revolta
		WorldState.STATE_REVOLUCAO:
			return revolucao
		_:
			return paz
