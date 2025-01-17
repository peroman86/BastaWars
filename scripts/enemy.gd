extends CharacterBody2D

@export var speed = 200.0
@export var gravity = 980.0
@export var throw_force = 600.0
@export var detection_range = 400.0
@export var throw_cooldown = 1.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var idle_sprite: Sprite2D = $IdleAnimation
@onready var run_sprite: Sprite2D = $RunAnimation
@onready var jump_sprite: Sprite2D = $JumpAnimation
@onready var throw_sound: AudioStreamPlayer = $ThrowSound

var health = 5
var ammo_count = 0
var max_ammo = 5
var facing_direction = -1  # 1 for right, -1 for left
var can_throw = true
var player = null
var Projectile = preload("res://scenes/projectile.tscn")
var initial_position = Vector2.ZERO
var ammo_pile_position = Vector2.ZERO
var seeking_ammo = false
var is_aggressive = false  # Controls if enemy is actively fighting
var game_manager = null
var battle_active = true  # Track if enemy can act

func _ready():
	# Store initial position
	initial_position = position
	
	# Add to enemy group
	add_to_group("enemy")
	
	# Find game manager
	game_manager = get_parent()
	
	# Find the player node
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Warning: Player node not found!")
	
	# Find the enemy ammo pile
	var ammo_pile = get_parent().get_node("EnemyAmmoPile")
	if ammo_pile:
		ammo_pile_position = ammo_pile.position
	
	# Initialize animations
	animation_tree.active = true
	run_sprite.hide()
	jump_sprite.hide()

func _process(_delta):
	update_animation_tree()
	update_active_sprite()

func _physics_process(delta):
	if not battle_active:
		return
		
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if player:
		# Calculate distance to player
		var distance = position.distance_to(player.position)
		
		# Become aggressive if player is very close
		if distance < detection_range:
			is_aggressive = true
		
		# Only act if aggressive
		if is_aggressive:
			# Update facing direction based on player position
			facing_direction = sign(player.position.x - position.x)
			# Update sprite direction
			scale.x = -facing_direction
			
			# If we're out of ammo, go get some
			if ammo_count == 0:
				seeking_ammo = true
			
			if seeking_ammo:
				# Move towards ammo pile
				var direction_to_ammo = sign(ammo_pile_position.x - position.x)
				velocity.x = direction_to_ammo * speed
				
				# If close to ammo pile, we can stop seeking
				if abs(position.x - ammo_pile_position.x) < 50:
					seeking_ammo = false
			else:
				# Always chase player when not seeking ammo
				velocity.x = facing_direction * speed
				
				# Try to throw ammo if we have it and player is in range
				if can_throw and ammo_count > 0 and distance < detection_range:
					throw_ammo()
		else:
			# When not aggressive, just face the player's direction
			facing_direction = sign(player.position.x - position.x)
			scale.x = -facing_direction
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func update_animation_tree():
	animation_tree["parameters/conditions/idle"] = is_on_floor() and velocity.x == 0
	animation_tree["parameters/conditions/is_moving"] = is_on_floor() and velocity.x != 0

func update_active_sprite():
	idle_sprite.visible = is_on_floor() and velocity.x == 0
	run_sprite.visible = is_on_floor() and velocity.x != 0
	jump_sprite.visible = not is_on_floor()

func throw_ammo():
	if ammo_count <= 0:
		return
		
	ammo_count -= 1
	can_throw = false
	
	# Play throw sound
	if throw_sound:
		throw_sound.play()
	
	var projectile = Projectile.instantiate()
	projectile.position = position + Vector2(facing_direction * 30, 0)
	projectile.set_source(false)  # Mark as enemy projectile
	get_parent().add_child(projectile)
	projectile.throw(facing_direction * throw_force)
	
	# Reset throw cooldown
	await get_tree().create_timer(throw_cooldown).timeout
	can_throw = true

func collect_ammo(amount: int):
	if not battle_active or ammo_count >= max_ammo:
		return
	ammo_count = min(ammo_count + amount, max_ammo)
	seeking_ammo = false

func take_damage():
	# Become aggressive when hit
	is_aggressive = true
	
	health -= 1
	if health <= 0:
		if game_manager:
			game_manager.enemy_died()
		hide()

func respawn():
	# Respawn enemy with full health and no ammo
	show()
	health = 5
	ammo_count = 0
	position = initial_position
	velocity = Vector2.ZERO
	seeking_ammo = false
	is_aggressive = false  # Reset aggression on respawn

func set_battle_active(active: bool):
	battle_active = active
	if not battle_active:
		velocity = Vector2.ZERO
