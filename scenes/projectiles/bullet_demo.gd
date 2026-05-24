class_name BulletDemo extends Node2D

## Velocidade de deslocamento do projétil em pixels por segundo.
var speed = 0
## Quantidade de dano que o projétil causará ao atingir um alvo.
var damage = 0

## Inicializa os atributos da bala no momento em que ela é instanciada.
func setup(bullet_speed: float, bullet_damage: int) -> void:
	speed = bullet_speed
	damage = bullet_damage


## Move o projétil continuamente na direção de seu eixo X local.
func _physics_process(delta: float) -> void:
	# transform.x representa o vetor "frente" da bala com base na rotação atual dela
	position += transform.x * speed * delta


## Libera a memória e remove a bala do jogo assim que ela sai da tela.
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


## Detecta colisões com corpos físicos e aplica o dano se o alvo for válido.
func _on_hurtbox_body_entered(body: Node2D):
	# Duck typing: verifica se o objeto atingido possui a função de receber dano
	if body.has_method("take_damage"):
		body.take_damage(damage)
