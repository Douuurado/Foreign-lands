# O que falta — Ilha da Monarquia

Este commit deixa a arquitetura de sistema (GDD seção 9) 100% funcional e
integrada numa única cena jogável: `systems/core/game.tscn` já tem o Totem
*e* o pedaço essencial da ilha (1 NPC, 2 pontos de escolha, consequência na
arena, consequência visual) juntos, não em cenas separadas. O que falta
daqui pra frente é praticamente todo **conteúdo** — a arquitetura já dá
suporte a ele sem pedir código novo de sistema, só como o README de
`systems/world_state/` explica.

## 1. Prioridade alta — fecha o loop essencial pedido

- [ ] **As outras 2 variantes de inimigo da seção 3.2** — hoje Repressão/
	  Revolta/Revolução reaproveitam o mesmo `InimigoProvocador` como
	  placeholder. Faltam: prisioneiro rebelde acorrentado (Repressão — não
	  persegue o jogador, é "protegido" pelos guardas) e sabotador
	  (Revolta — mira o Totem, não o jogador). Cada um pede uma pequena
	  variação de comportamento no script, não só stats.
- [ ] **Testar a curva completa dentro do Editor** — como o `PoliticalChoice`
	  é repetível, dá pra empurrar `coroa` até 70+ e ver Repressão acontecer
	  de verdade (o que este commit não pôde rodar, por não ter acesso ao
	  Editor Godot aqui).
- [ ] **Replicar `PoliticalNPC` pros outros 6 NPCs** (seção 2): Capitã
	  Ysolda, Doren, Mãe Ivet, Conselheiro Aldric, Kessa, Tio Bram — cada
	  um só precisa de `_on_interact` + `_apply_current_state` própria,
	  igual `renata.gd`.

## 2. Conteúdo estrutural (pede cena/tilemap, não lógica nova)

- [ ] As 5 zonas da ilha (seção 1.1) como cenário de verdade — hoje só
	  existe o "miolo" (Totem + escolhas) dentro da cena da arena. Cais da
	  Vila Baixa, Distrito da Guarda, Colina Real (trancada por
	  `crown_favor >= 40`) e o Esconderijo (revelado por evento/Kessa)
	  ainda não têm tilemap.
- [ ] As 8 missões da seção 7, usando `WorldState.apply_reputation` e
	  `WorldState.set_mission_flag` a partir do *resultado* da jogatina
	  (não de menu) — os 2 `PoliticalChoice` atuais são um placeholder
	  funcional pra isso, não a versão final.
- [ ] Os 4 chefes da seção 3.3 (um por caminho: Coroa total, Rebelde total,
	  Motim Duplo por negligência, Reforma cooperativa).
- [ ] Eventos de mundo da seção 6 usando `systems/events/event_trigger.gd`
	  (já existe e não é usado por nenhuma cena ainda): emboscada à
	  cobrança, batida de guarda, recrutador clandestino, execução pública
	  agendada, filas de racionamento.
- [ ] Missão 8 "Negociar Trégua" e o caminho de Reforma (seção 8, estado
	  especial) — única saída não-violenta do arco.

## 3. Visual e produção (seção 5) — além do `CanvasModulate` básico

- [ ] Densidade de patrulha variável, pichações/cartazes trocáveis,
	  bandeiras por estado, barricadas físicas bloqueando rota em Revolta,
	  fachadas queimadas em Revolução.
- [ ] Arte de verdade pros 7 NPCs e pra Renata (hoje todos usam
	  `player.jpeg` tingido como placeholder).

## 4. Sistemas ainda sem dono

- [ ] Diálogo real (Renata e o TODO em `renata.gd` só fazem `print`).
- [ ] Loja do Doren com estoque condicionado a `rebel_favor >= 35`
	  (seção 6 — preços e loot por facção).
- [ ] Atalhos de navegação por reputação alta (seção 6).
- [ ] UI final de reputação/estado — `ReputationDebug` no `game.tscn` é só
	  depuração de prototype, não pra ficar no jogo.
- [ ] Save/load real usando `WorldState.save_island` (o método já existe e
	  salva sozinho por ser `Resource`; falta só chamar em algum menu).

## 5. Fora do escopo desta ilha (gancho pro resto do jogo)

- [ ] Seção 10.4: contador global "emoções absorvidas" pro Remanescente,
	  alimentado pelo `latent_pressure` resolvido de cada ilha.
- [ ] Segunda ilha (Teocracia/Democracia/etc.) — arquitetura já suporta via
	  `IslandDefinition` novo, sem alterar código (seção 10.1–10.3).
