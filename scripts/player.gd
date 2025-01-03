extends CharacterBody2D

@export var speed = 300.0
@export var jump_force = -400.0
@export var gravity = 980.0
@export var throw_force = 600.0

var ammo_count = 0
var facing_direction = 1  # 1 for right, -1 for left
var Projectile = preload("res://scenes/projectile.tscn")

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	# Get horizontal input and update facing direction
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		facing_direction = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	# Handle throwing with F key
	if Input.is_action_just_pressed("fire") and ammo_count > 0:  # F key
		print("F key pressed, ammo count: ", ammo_count)
		throw_ammo()
	
	move_and_slide()

func throw_ammo():
	if ammo_count <= 0:
		return
		
	print("Throwing ammo, direction: ", facing_direction)
	ammo_count -= 1
	var projectile = Projectile.instantiate()
	projectile.position = position + Vector2(facing_direction * 30, 0)
	projectile.modulate = Color(1, 0, 0)
	get_parent().add_child(projectile)
	projectile.throw(facing_direction * throw_force)
	print("Projectile added at position: ", projectile.position)

func collect_ammo(amount: int):
	ammo_count += amount
	print("Collected ammo, total: ", ammo_count)
