extends Area2D

@export var ammo_amount = 1
var enemy_in_range = false
var current_enemy = null
var can_collect = true
var cooldown_time = 0.1

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta):
	if enemy_in_range and can_collect:
		if current_enemy.has_method("collect_ammo"):
			current_enemy.collect_ammo(ammo_amount)
			can_collect = false
			get_tree().create_timer(cooldown_time).timeout.connect(reset_cooldown)

func reset_cooldown():
	can_collect = true

func _on_body_entered(body):
	# Check if it's an enemy (using script name as identifier)
	if body.get_script() and body.get_script().resource_path.ends_with("enemy.gd"):
		enemy_in_range = true
		current_enemy = body

func _on_body_exited(body):
	if body == current_enemy:
		enemy_in_range = false
		current_enemy = null 
