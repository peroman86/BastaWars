extends RigidBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bomb_sprite: Sprite2D = $BombOnAnimation
@onready var boom_sprite: Sprite2D = $BoomAnimation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_sound: AudioStreamPlayer = $ExplosionSound

var thrown = false
var hit_wall = false
var floor_y = 550  # Same Y position as the floor in world scene
var is_player_projectile = false  # Track who fired the projectile
var knockback_force = Vector2(400, -300)  # Horizontal and vertical knockback

func _ready():
	gravity_scale = 1.5
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", _on_body_entered)
	scale = Vector2(2, 2)
	animation_tree.active = true
	boom_sprite.hide()

func _process(_delta):
	update_animation_tree()

func _physics_process(_delta):
	if position.y >= floor_y:  # If projectile is at or below floor level
		explode()
		return

func throw(force: float):
	thrown = true
	apply_central_impulse(Vector2(force, -600))

func set_source(from_player: bool):
	is_player_projectile = from_player
	# Keep original sprite, just track the source for gameplay logic

func apply_knockback(body: CharacterBody2D):
	# Calculate direction from explosion to body
	var direction = (body.position - position).normalized()
	# Apply horizontal knockback in the direction of impact
	var knockback = Vector2(knockback_force.x * direction.x, knockback_force.y)
	body.velocity = knockback

func _on_body_entered(body):
	if not thrown:
		return
		
	if body is StaticBody2D:
		explode()
	elif body.has_method("take_damage"):
		# Check if projectile hits the correct target
		var hit_player = body.get_script().resource_path.ends_with("player.gd")
		
		if (is_player_projectile and not hit_player) or (not is_player_projectile and hit_player):
			body.take_damage()
			if body is CharacterBody2D:
				apply_knockback(body)
			explode()

func explode():
	hit_wall = true
	# Completely stop all movement
	freeze = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Play explosion sound
	if explosion_sound:
		explosion_sound.play()
	
	# Show explosion sprite
	update_active_sprite()
	# Wait for explosion animation to finish
	await get_tree().create_timer(0.5).timeout
	queue_free()

func update_active_sprite():
	if hit_wall:
		bomb_sprite.hide()
		boom_sprite.show()

func update_animation_tree():
	animation_tree['parameters/conditions/thrown'] = thrown
	animation_tree['parameters/conditions/exploded'] = hit_wall
