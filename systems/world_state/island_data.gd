## Estado MUTÁVEL real de uma ilha durante a partida (GDD seção 9.3): favor de
## cada facção, pressão latente acumulada e flags de missão/mundo. Só o
## WorldState tem permissão de escrever aqui — ver a regra de ouro da seção 9.1.
##
## Por ser um Resource, se salva sozinho com ResourceSaver.save() (seção 9.7) —
## o projeto ainda não tem nenhum sistema de save, e isso resolve o de ilha
## de graça, sem inventar um formato de arquivo próprio.
class_name IslandData extends Resource

## Deve bater com o island_id da IslandDefinition correspondente.
@export var island_id: StringName = &""

## Favor de cada facção, indexado por nome — ex: {&"coroa": 50, &"rebeldes": 15}.
## Fica em dicionário, não em duas variáveis fixas tipo crown_favor/rebel_favor,
## porque isso é o que permite reaproveitar a mesma classe pra qualquer
## ideologia futura sem alterar uma linha de código (seção 10.1).
@export var faction_favor: Dictionary = {}

## Sobe +N automaticamente a cada ciclo do Totem (seção 4.1) — o rei continua
## subindo impostos com ou sem a interferência do jogador.
@export var latent_pressure: int = 0

## Flags de missão e de mundo, ex: {&"execucao_impedida": true} (seção 8/9.3).
@export var mission_flags: Dictionary = {}

## Estado atual (Paz/Tensão/Repressão/Revolta/Revolução). É sempre CALCULADO
## por WorldState._recompute_state — nunca setado à mão em outro lugar. Fica
## exportado aqui só pra leitura rápida e pra sobreviver ao save/load.
@export var current_state: StringName = &"paz"
