extends CharacterBody2D

## Velocidade de deslocamento do inimigo durante a perseguição.
@export var speed : int = 200
## Quantidade máxima de pontos de vida que o inimigo possui.
@export var max_health : int = 3
## Quantidade de dano que este inimigo causa ao atingir o jogador.
@export var damage_amount : int = 1

## Armazena a referência do nó que o inimigo está perseguindo (ex: o Player).
var target = null
## Controla se o comportamento de perseguição está ativo no momento.
var target_chase = false

## Registra o inimigo no gerenciador global de vida ao entrar na cena.
func _ready():
	get_node("/root/EnemyHealthManager").register_enemy(self, max_health)

## Executa a movimentação de perseguição usando a física nativa para evitar atravessar paredes.
func _physics_process(_delta: float) -> void:
	if target_chase and target:
		# Calcula a direção exata usando posições globais
		var direction = global_position.direction_to(target.global_position)
		
		# Define a velocidade nativa do CharacterBody2D
		velocity = direction * speed
		
		# Aplica o movimento tratando colisões com o cenário (não precisa multiplicar por delta)
		move_and_slide()
	else:
		# Zera a velocidade caso não esteja perseguindo ninguém, parando o inimigo suavemente
		velocity = Vector2.ZERO
		
## Define o corpo detectado como alvo e ativa o estado de perseguição.
func _on_detection_area_body_entered(body: Node2D) -> void:
	target = body
	target_chase = true
		
## Limpa a referência do alvo e interrompe a perseguição quando ele se afasta.
func _on_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	target_chase = false
	
## Encaminha a solicitação de redução de vida para o gerenciador central de inimigos.
func take_damage(amount):
	get_node("/root/EnemyHealthManager").damage_enemy(self, amount)
