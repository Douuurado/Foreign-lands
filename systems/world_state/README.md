## Sistema Político (Ilha da Monarquia) — o que já existe

Implementação da arquitetura descrita em `ilha-da-monarquia-gdd.md`, seção 9,
seguindo a ordem de risco mínimo que o próprio GDD recomenda (seção 9.8).

### ✅ Passo 1 — Dados + Autoridade
- `island_definition.gd` (`IslandDefinition`) — dados autorados por ilha.
- `island_data.gd` (`IslandData`) — estado mutável (favor, pressão, flags).
- `world_state.gd` (autoload `WorldState`) — único lugar que escreve o
  estado. Carrega toda ilha salva em `res://resources/islands/*.tres`
  automaticamente; se a pasta estiver vazia, usa Vaelmoor com os valores
  padrão do GDD (seção 4.1) como fallback.
- **Testar:** rode o jogo e observe no output `print` (adicione um
  `print(WorldState.get_state(&"vaelmoor"))` em qualquer `_ready()` pra
  confirmar). Chame `WorldState.apply_reputation(&"vaelmoor", {&"coroa": -12,
  &"rebeldes": 15})` de algum lugar de teste e veja o estado mudar.

### ✅ Passo 2 — Totem ligado à EncounterTable
- `encounter_table.gd` (`EncounterTable`) — tabela de inimigos por estado.
- `totem.gd` ganhou `island_id` e `encounter_table` (ambos opcionais — sem
  eles, o Totem se comporta exatamente como antes).
- O Totem de `game.tscn` já está com `island_id = "vaelmoor"`. Sem uma
  `EncounterTable` arrastada no Inspector, ele continua spawnando
  `enemy_scene` normalmente — mas já está ticando `latent_pressure` a cada
  wave (seção 4.1) e recalculando o estado.
- **Falta:** criar as cenas de inimigo variantes (provocador, prisioneiro
  acorrentado, sabotador — seção 3.2) e montar uma `EncounterTable.tres`
  pra Vaelmoor com elas.

### ✅ Passo 3 — Um NPC político (validação do padrão)
- `political_npc.gd` (`PoliticalNPC`) — classe-base, seção 9.5.
- `scenes/npcs/renata/renata.gd` — Renata (seção 2) como exemplo concreto.
  Falta anexar a uma cena de verdade (`StaticBody2D` + `Interactable` +
  `Sprite2D`, igual ao padrão de `systems/totem/totem.tscn`) quando a arte
  dela existir.
- **Próximo:** replicar o padrão pros outros seis NPCs (Ysolda, Doren, Mãe
  Ivet, Aldric, Kessa, Bram) — cada um só precisa de `_on_interact` e
  `_apply_current_state` próprios.

### ✅ Passo 4 (mínimo) — Visual
`systems/world_state/island_mood_modulate.gd` — `CanvasModulate` que tinge a
cena conforme `WorldState.state_changed`, exatamente a sugestão técnica da
seção 5. Cobre só o "80% do impacto emocional por 20% do custo" citado no
GDD — patrulha, pichação, bandeiras e fachadas trocadas continuam
pendentes (conteúdo real, não sistema).

### ✅ Prototype integrado (ilha + arena na MESMA cena)
`systems/core/game.tscn` agora tem, junto com o Totem, o pedaço essencial
da Ilha da Monarquia — não como cena separada:
- `Renata` (scenes/npcs/renata/renata.tscn) — primeiro `PoliticalNPC` com
  cena de verdade, reagindo ao estado ao vivo.
- Dois `PoliticalChoice` (systems/choices/) — pontos de escolha repetíveis
  que aplicam deltas de reputação da tabela 4.2 (substituem, por ora, as
  8 missões reais da seção 7, que ainda não existem).
- `EncounterTable` de Vaelmoor (resources/islands/vaelmoor_encounter_table.tres)
  ligada ao Totem, com uma variante de inimigo (`InimigoProvocador`, mais
  rápido e frágil) reaproveitada nos estados Tensão/Repressão/Revolta/
  Revolução — só pra provar que a troca de inimigo por estado funciona.
  As variantes com comportamento realmente distinto por estado
  (prisioneiro acorrentado, sabotador) ainda faltam.
- `ReputationDebug` — Label de depuração (não é UI final) pra ver
  favor/pressão/estado mudando em tempo real ao testar.

Sequência pra testar no Editor: rode `game.tscn` → interaja com um dos
`PoliticalChoice` várias vezes → veja o label de depuração subir os
números → ative o Totem e note que o inimigo spawnado muda quando o
estado passa de Paz pra Tensão/Repressão → note a cor da cena mudando.
Ver `PROXIMOS-PASSOS.md` na raiz do projeto pra lista completa do que
falta.

### Também incluído (fora da ordem 9.8, mas pequeno)
- `systems/events/event_trigger.gd` (`EventTrigger`) — gatilho de evento de
  mundo por `Area2D`, seção 9.2/9.6. Ainda não há nenhum evento de mundo
  (seção 6) usando isso — é só a peça pronta pra quando alguém for montar a
  primeira emboscada/batida de guarda.

### O que ESTE commit não cobre
As cinco zonas da ilha (seção 1), as 8 missões (seção 7), os diálogos reais
dos 7 NPCs e os 4 chefes (seção 3.3) são conteúdo — pedem cena, tilemap, arte
e escrita reais que a arquitetura acima só dá suporte para. Nada disso
precisa de código novo na camada de sistema; é só usar o que já existe
(`WorldState.apply_reputation`, `PoliticalNPC`, `EventTrigger`,
`WorldState.set_mission_flag`) dentro de cada cena de conteúdo.
