extends CharacterBody2D

@export var speed = 300.0
@export var jump_force = -400.0
@export var gravity = 980.0
@export var throw_force = 600.0

var ammo_count = 0
var max_ammo = 5
var facing_direction = 1  # 1 for right, -1 for left
var Projectile = preload("res://scenes/projectile.tscn")
var ammo_label: Label
var controls_label: Label

func _ready():
	# Create UI canvas layer
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Create ammo counter UI
	ammo_label = Label.new()
	ammo_label.position = Vector2(20, 20)
	ammo_label.text = "Ammo: 0/5"
	canvas_layer.add_child(ammo_label)
	
	# Create controls display
	controls_label = Label.new()
	controls_label.position = Vector2(20, 50)
	controls_label.text = """Controls:
Move: Left/Right Arrow Keys
Jump: Space Bar
Collect Ammo: Press E near ammo pile
Throw: Press X (needs ammo)"""
	canvas_layer.add_child(controls_label)
	
	update_ammo_display()

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
	
	# Handle throwing
	if Input.is_action_just_pressed("fire") and ammo_count > 0:
		print("Fire pressed, ammo count: ", ammo_count)
		throw_ammo()
	
	move_and_slide()

func throw_ammo():
	if ammo_count <= 0:
		return
		
	print("Throwing ammo, direction: ", facing_direction)
	ammo_count -= 1
	update_ammo_display()
	var projectile = Projectile.instantiate()
	projectile.position = position + Vector2(facing_direction * 30, 0)
	projectile.modulate = Color(1, 0, 0)
	get_parent().add_child(projectile)
	projectile.throw(facing_direction * throw_force)
	print("Projectile added at position: ", projectile.position)

func collect_ammo(amount: int):
	if ammo_count >= max_ammo:
		return
	ammo_count = min(ammo_count + amount, max_ammo)
	update_ammo_display()
	print("Collected ammo, total: ", ammo_count)

func update_ammo_display():
	if ammo_label:
		ammo_label.text = "Ammo: " + str(ammo_count) + "/" + str(max_ammo)
