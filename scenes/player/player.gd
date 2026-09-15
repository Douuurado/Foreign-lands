class_name Player
extends CharacterBody2D

## Velocidade máxima base de movimentação do jogador.
const SPEED = 300.0
## Controla se o jogador está temporariamente imune a novas fontes de dano.
var invulnerable = false
## Tempo de duração (em segundos) do estado de invulnerabilidade após ser atingido.
var invulnerability_time = 0.5

## Velocidade máxima base do dash
const DASH_SPEED = 800.0
## Duração de tempo do dash (0.1 da velocidade = 80 pixels)
const DASH_DURATION = 0.1
## Duração de tempo até poder usar outro dash
const DASH_COOLDOWN = 0.5

## Controla a movimentação do dash
var is_dashing = false
## Controla se o dash pode ocorrer de novo ou não
var can_dash = true
## Inicializa a direção do dash no vetor (0,0)
var dash_direction = Vector2.ZERO

## Referência ao nó de sprite que renderiza o corpo do personagem.
@onready var player_sprite = get_node("Body")

@onready var hand_right: Marker2D = $HandRight
@onready var hand_left: Marker2D = $HandLeft

# --- Inventário de armas ---
# Pré-carrega as cenas das armas. Ajuste os caminhos conforme o seu projeto.
var thompson_scene: PackedScene = preload("res://scenes/guns/thompson/thompson.tscn")
var pistol_scene: PackedScene = preload("res://scenes/guns/pistol/pistol.tscn")

# Posição no array = tecla - 1 (armas[0] -> tecla 1, armas[1] -> tecla 2)
var armas: Array[PackedScene] = []
var arma_atual_index: int = -1
var arma_atual_no: Node = null  # referência à instância da arma equipada agora

func _ready() -> void:
	armas = [thompson_scene, pistol_scene]
	trocar_arma(0)  # começa equipando a Thompson

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				trocar_arma(0)  # Thompson
			KEY_2:
				trocar_arma(1)  # Pistola

## Troca a arma equipada pelo índice do array "armas".
func trocar_arma(indice: int) -> void:
	if indice < 0 or indice >= armas.size():
		return
	if indice == arma_atual_index and arma_atual_no != null:
		return  # já está equipada, não faz nada

	arma_atual_index = indice

	# Remove a arma que está na mão agora, se houver uma
	if arma_atual_no != null:
		arma_atual_no.queue_free()
		arma_atual_no = null

	equip_weapon(armas[indice])

## Instancia a cena da arma e a equipa nas mãos do jogador.
func equip_weapon(scene: PackedScene) -> void:
	var gun = scene.instantiate()
	add_child(gun)
	gun.hand_right = hand_right
	gun.hand_left = hand_left
	arma_atual_no = gun

## Inicializa e atualiza movimentação e posição do mouse e sprite a cada frame de física.
func _physics_process(_delta: float) -> void:
	# Realiza a movimentação do dash quando ativado
	if is_dashing:
		velocity = dash_direction * DASH_SPEED
		move_and_slide()
		return

	# Captura os inputs do teclado ou controle (A, D, W, S / Setas)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Pega a posição global do cursor do mouse na tela
	var mouse_pos = get_global_mouse_position()

	# Calcula o vetor de direção normalizado do personagem até o mouse
	var direction_to_mouse = (mouse_pos - global_position).normalized()

	# Se houver direção de movimento ativa, aplica a velocidade máxima nela
	if direction != Vector2.ZERO:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	# Caso contrário, desacelera o personagem instantaneamente até parar
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and can_dash:
		if direction != Vector2.ZERO:
			start_dash(direction)
		else:
			start_dash(Vector2.RIGHT)

	# Atualiza os sprites e direções da animação com base na posição do mouse e movimento
	update_animation(direction_to_mouse, velocity.length() > 1.0)

	# Move o personagem pelo cenário aplicando a velocidade e tratando colisões automaticamente
	move_and_slide()

## Atualiza a animação e direção do sprite com base no mouse e movimento.
func update_animation(direction_to_mouse: Vector2, is_moving: bool) -> void:
	var anim = ""
	# Define se a animação é de andar ou parado
	var moving_suffix = "_walk" if is_moving else "_idle"

	# Diagonal superior (olhando para trás e lados)
	if abs(direction_to_mouse.x) > 0.5 and direction_to_mouse.y < -0.5:
		anim = "back_side"
		player_sprite.flip_h = direction_to_mouse.x < 0
	# Movimento predominantemente horizontal
	elif abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
		anim = "side"
		player_sprite.flip_h = direction_to_mouse.x < 0
	# Movimento predominantemente vertical (Frente/Trás)
	else:
		anim = "front" if direction_to_mouse.y > 0 else "back"

	# Combina a direção com o estado de movimento (ex: "side_walk")
	var final_anim = anim + moving_suffix

	# Executa a nova animação apenas se ela já não estiver tocando
	if $AnimationPlayer.current_animation != final_anim:
		$AnimationPlayer.play(final_anim)

## Processa o dano recebido quando um inimigo entra na área de colisão.
func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Verifica se o objeto é um inimigo e se o jogador pode tomar dano
	if body.is_in_group("enemy") and not invulnerable:
		invulnerable = true
		$AnimationPlayer.play("hit_flash")  # Pisca o sprite indicando dano
		HealthManager.decrease_health(body.damage_amount)

		# Aguarda o fim do tempo de invulnerabilidade
		await get_tree().create_timer(invulnerability_time).timeout
		invulnerable = false

## Configura o estado do dash (liga ou desliga o dash)
func start_dash(direction: Vector2) -> void:
	# Liga as variáveis do estado do dash
	can_dash = false
	is_dashing = true

	# Normaliza a direção para torná-la tamanho 1 (evita diagonais crescerem rápido)
	dash_direction = direction.normalized()

	# Torna o jogador invulnerável durante o dash
	invulnerable = true

	# Duração de tempo que o dash se manterá ativo
	await get_tree().create_timer(DASH_DURATION).timeout

	# Desliga as variáveis do estado do dash
	is_dashing = false
	invulnerable = false

	# Espera o cooldown
	await get_tree().create_timer(DASH_COOLDOWN).timeout

	can_dash = true
