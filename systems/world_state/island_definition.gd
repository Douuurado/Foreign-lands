## Dados AUTORADOS e fixos de uma ilha (GDD seção 9.3): quais facções existem,
## os limiares numéricos que definem cada um dos cinco estados (seção 8) e a
## EncounterTable que o Totem dessa ilha consulta. Um recurso desses = uma
## ilha. Cria-se no Inspector (Novo Recurso > IslandDefinition), arrastando —
## sem escrever código novo por ilha (seção 10.1).
##
## Pra criar a segunda ilha do jogo, é só salvar um IslandDefinition novo
## dentro de res://resources/islands/ — o WorldState carrega a pasta inteira
## sozinho, não precisa registrar em lugar nenhum.
class_name IslandDefinition extends Resource

## Identificador único da ilha (ex: &"vaelmoor"). É a chave que WorldState,
## Totem e PoliticalNPC usam pra saber de qual ilha estão falando.
@export var island_id: StringName = &""
## Nome de exibição (ex: "Vaelmoor").
@export var display_name: String = ""

## Nomes das facções desta ilha. IslandData guarda o favor de cada uma num
## dicionário indexado por esses mesmos nomes (seção 9.3 / 10.1) — o que
## permite reaproveitar a mesma classe pra Teocracia, Democracia, etc.
## O índice 0 faz o papel de "crown_favor" nas fórmulas da seção 8; o
## índice 1 faz o papel de "rebel_favor". Precisa de pelo menos 2 facções.
@export var faction_ids: Array[StringName] = [&"coroa", &"rebeldes"]
## Favor inicial de cada facção, na mesma ordem de faction_ids.
## Vaelmoor (seção 4.1): Coroa começa em 50 (legitimidade já estabelecida),
## Rebeldes começa em 15 (rebelião nascente).
@export var starting_favor: Array[int] = [50, 15]

## Limiares que definem os cinco estados — ver a tabela da seção 8 do GDD.
## Os valores padrão abaixo já são os de Vaelmoor; troque pra outra ilha.
@export_group("Limiares de Estado (seção 8)")
## Revolução: favor_a E favor_b >= este valor (armar os dois lados).
@export var revolution_favor_threshold: int = 70
## Revolução: OU latent_pressure >= este valor (negligência).
@export var revolution_pressure_threshold: int = 100
## Repressão/Revolta: a facção dominante precisa estar >= este valor.
@export var domination_high_threshold: int = 70
## Repressão/Revolta: a outra facção precisa estar < este valor.
@export var domination_low_threshold: int = 55
## Tensão: latent_pressure >= este valor...
@export var tension_pressure_threshold: int = 25
## ...OU favor_b (equivalente a rebel_favor) >= este valor.
@export var tension_favor_threshold: int = 40

## Seção 4.1: latent_pressure sobe sozinha a cada ciclo do Totem, e acima do
## limiar de "fuga de controle" o favor_b (rebeldes) também sobe sozinho.
@export_group("Pressão Latente (seção 4.1)")
@export var pressure_per_cycle: int = 3
@export var pressure_runaway_threshold: int = 60
@export var runaway_favor_b_gain: int = 1

## Tabela de inimigos por estado que o Totem desta ilha consulta (seção 9.3/9.4).
@export_group("Referências")
@export var encounter_table: EncounterTable
