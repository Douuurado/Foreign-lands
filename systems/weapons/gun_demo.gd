class_name GunDemo extends Node2D

## Distância mínima (em pixels) para o mouse começar a rotacionar a arma.
const MIN_DISTANCE = 8

## Tempo de espera (em segundos) entre cada disparo.
@export var fire_rate = 0.2
## Velocidade do projétil disparado.
@export var bullet_speed = 1000
## Dano padrão causado pelo projétil.
@export var damage = 10
## Ângulo máximo de imprecisão/espalhamento (em graus) dos tiros.
@export var spread = 0

## Cronômetro interno que acumula o tempo desde o último tiro realizado.
var last_time_shot = 0.0
## Limiar de ângulo usado para inverter a arma (não utilizado diretamente nesta lógica).
var flip_threshold = 135
## Controla se a arma está atualmente apontada para o lado esquerdo do cenário.
var facing_left := false

## Cena do projétil que será instanciada a cada disparo.
var bullet_scene = preload("res://scenes/projectiles/bullet_demo.tscn")
## Ponto de saída do tiro na ponta do cano da arma.
@onready var muzzle : Marker2D = $Marker2D

## Controla a rotação da arma em direção ao mouse, inverte o sprite e gerencia o input de tiro.
func _physics_process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var direction = mouse_pos - global_position

	# Evita trepidação extrema da rotação caso o mouse esteja em cima do pivô da arma
	if direction.length_squared() <= MIN_DISTANCE * MIN_DISTANCE:
		return

	# Aponta a arma na direção do cursor do mouse
	look_at(mouse_pos)

	# Converte o ângulo atual do vetor de radianos para graus
	var angle = rad_to_deg(direction.angle())

	# Sistema anti-flicker: evita que o sprite fique piscando/invertendo na transição vertical
	if facing_left:
		# Se estava olhando para a esquerda e o mouse entrou no quadrante direito, desverte
		if angle < 80 and angle > -80:
			facing_left = false
	else:
		# Se estava olhando para a direita e o mouse entrou no quadrante esquerdo, inverte
		if angle > 100 or angle < -100:
			facing_left = true
			
	# Inverte o eixo vertical do sprite para a arma não ficar de cabeça para baixo ao olhar para a esquerda
	$Sprite2D.flip_v = facing_left	
	# Ajusta a posição e o cano (muzzle) baseado no lado em que a arma está apontada
	position.x = -6 if facing_left else 6
	muzzle.position.y = 6 if facing_left else 0

	# Incrementa o temporizador de disparo
	last_time_shot += delta

	# Verifica se a tecla de tiro está pressionada e se o cooldown terminou
	if Input.is_action_pressed("shoot") and last_time_shot >= fire_rate:
		shoot()
	
## Cria a instância do projétil no mundo, aplica a precisão (spread) e define seus atributos básicos.
func shoot():
	# Reinicia o temporizador do cadência de tiro
	last_time_shot = 0.0
	
	# Instancia a bala diretamente na raiz da árvore de cenas atual
	var bullet_instance = bullet_scene.instantiate()
	get_tree().root.add_child(bullet_instance)
	
	# Posiciona a bala no cano da arma
	bullet_instance.global_position = muzzle.global_position
	
	# Calcula e aplica um ângulo aleatório de dispersão baseado na imprecisão da arma
	var spread_angle = randf_range(-spread, spread)
	bullet_instance.global_rotation =  global_rotation + deg_to_rad(spread_angle)
	
	# Duck typing: passa os parâmetros de velocidade e dano se a bala possuir o método setup
	if bullet_instance.has_method("setup"):
		bullet_instance.setup(bullet_speed, damage)
	else:
		print("Method 'setup' not identified or inserted")
		
	# Toca o efeito sonoro do disparo
	#$shoot_sound.play() Deve ser adicionado o som
