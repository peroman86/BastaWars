extends RigidBody2D

var thrown = false
var floor_y = 550  # Same Y position as the floor in world scene

func _ready():
	gravity_scale = 1.5
	contact_monitor = true
	max_contacts_reported = 1
	connect("body_entered", _on_body_entered)
	modulate = Color(1, 0, 0)
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
	if thrown and (body is StaticBody2D):
		print("Hit something!")
		queue_free()
