extends Node

var player
var enemy
var camera
var battle_over_label: Label
var respawn_button: Button
var canvas_layer: CanvasLayer
var battle_in_progress = true  # Track if battle is active
var background_music: AudioStreamPlayer

func _ready():
	# Setup background music
	background_music = AudioStreamPlayer.new()
	var music = load("res://assets/music/background.mp3")
	if music:
		print("Music loaded successfully")
		background_music.stream = music
		background_music.volume_db = -10  # Slightly lower volume
		background_music.autoplay = true
		background_music.stream.loop = true  # Enable looping
		add_child(background_music)
		background_music.play()
	else:
		print("Failed to load music file")

	# Create UI layer
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Create container for centered UI
	var container = Control.new()
	container.set_anchors_preset(Control.PRESET_FULL_RECT)  # Make container fill the screen
	canvas_layer.add_child(container)
	
	# Create battle over label
	battle_over_label = Label.new()
	battle_over_label.add_theme_font_size_override("font_size", 32)
	battle_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	battle_over_label.set_anchors_preset(Control.PRESET_CENTER)  # Center in parent
	battle_over_label.hide()
	container.add_child(battle_over_label)
	
	# Create respawn button
	respawn_button = Button.new()
	respawn_button.text = "Respawn Players"
	respawn_button.custom_minimum_size = Vector2(200, 50)
	respawn_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	respawn_button.set_anchors_preset(Control.PRESET_CENTER)  # Center in parent
	respawn_button.position = Vector2(0, 100)  # Offset below the label
	respawn_button.hide()
	respawn_button.pressed.connect(_on_respawn_pressed)
	container.add_child(respawn_button)
	
	# Find nodes
	player = get_node("Player")
	enemy = get_node("Enemy")
	if player:
		camera = player.get_node("Camera2D")

func player_died():
	battle_over_label.text = "Enemy Wins!"
	end_battle()

func enemy_died():
	battle_over_label.text = "Player Wins!"
	end_battle()

func end_battle():
	battle_in_progress = false
	show_battle_over()
	
	# Notify players that battle is over
	if player and player.has_method("set_battle_active"):
		player.set_battle_active(false)
	if enemy and enemy.has_method("set_battle_active"):
		enemy.set_battle_active(false)

func show_battle_over():
	battle_over_label.show()
	respawn_button.show()
	
	# Hide player and enemy
	if player:
		player.hide()
	if enemy:
		enemy.hide()

func _on_respawn_pressed():
	# Hide UI
	battle_over_label.hide()
	respawn_button.hide()
	
	# Reset battle state
	battle_in_progress = true
	
	# Respawn and show both characters
	if player:
		player.show()
		player.respawn()
		player.set_battle_active(true)
	if enemy:
		enemy.show()
		enemy.respawn()
		enemy.set_battle_active(true)

func _process(_delta):
	# Loop the music
	if not background_music.playing:
		background_music.play() 
