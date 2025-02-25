extends Area2D

@export var ammo_amount = 1
var player_in_range = false
var current_player = null
var can_collect = true
var cooldown_time = 0.1  # reduced cooldown time

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("collect") and can_collect:
		if current_player.has_method("collect_ammo"):
			current_player.collect_ammo(ammo_amount)
			can_collect = false
			get_tree().create_timer(cooldown_time).timeout.connect(reset_cooldown)

func reset_cooldown():
	can_collect = true

func _on_body_entered(body):
	if body.has_method("collect_ammo"):
		player_in_range = true
		current_player = body

func _on_body_exited(body):
	if body == current_player:
		player_in_range = false
		current_player = null 
