extends RigidBody2D

var thrown = false
var floor_y = 550  # Same Y position as the floor in world scene

func _ready():
	gravity_scale = 1.5
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", _on_body_entered)
	scale = Vector2(2, 2)
	print("Projectile created at: ", position)

func _physics_process(_delta):
	if position.y >= floor_y:  # If projectile is at or below floor level
		queue_free()
		return

func throw(force: float):
	thrown = true
	print("Throwing with force: ", force)
	apply_central_impulse(Vector2(force, -600))

func _on_body_entered(body):
	if not thrown:
		return
		
	if body is StaticBody2D:
		print("Hit wall!")
		queue_free()
	elif body.has_method("take_damage"):
		# Only damage if the projectile color doesn't match the body
		# Red projectiles (from player) damage blue enemies
		# Blue projectiles (from enemy) damage the player
		var is_player_projectile = modulate == Color(1, 0, 0)  # Red
		var hit_player = body.get_script().resource_path.ends_with("player.gd")
		
		if (is_player_projectile and not hit_player) or (not is_player_projectile and hit_player):
			print("Hit character!")
			body.take_damage()
			queue_free()
