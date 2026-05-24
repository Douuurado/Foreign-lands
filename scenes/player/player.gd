class_name Player extends CharacterBody2D

## Velocidade máxima base de movimentação do jogador.
const SPEED = 300.0
## Controla se o jogador está temporariamente imune a novas fontes de dano.
var invulnerable = false
## Tempo de duração (em segundos) do estado de invulnerabilidade após ser atingido.
var invulnerability_time = 0.5

## Referência ao nó de sprite que renderiza o corpo do personagem.
@onready var player_sprite = get_node("Body")

## Inicializa e atualiza movimentação e posição do mouse e sprite a cada frame de física.
func _physics_process(_delta: float) -> void:
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
		$AnimationPlayer.play("hit_flash") # Pisca o sprite indicando dano
		HealthManager.decrease_health(body.damage_amount)
		
		# Aguarda o fim do tempo de invulnerabilidade
		await get_tree().create_timer(invulnerability_time).timeout
		invulnerable = false
