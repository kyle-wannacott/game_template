extends CharacterBody2D

@onready var save_game_filepath := ("user://savegame.tres")
@onready var game_config_path := ("user://game_settings.cfg")

# @onready var saved_game:SavedGame = SavedGame.new()
# @onready var loaded_game:SavedGame = load(save_game_filepath) as SavedGame
@onready var resources := get_tree().get_first_node_in_group("resources")
@onready var game_config:ConfigFile = ConfigFile.new()
@onready var settings_menu = %settings_menu
@onready var drone_type := "base"

@onready var can_rotate := false
var move_vec=Vector2()
func _physics_process(delta):
	# if is_disabled: velocity = Vector2(0,0)
	move_vec= player_direction()
	velocity = move_vec *(500)
	move_and_slide()# if Input.is_action_just_pressed()
	if can_rotate: global_rotation = calculate_player_rotation(rotation_weight)
	queue_redraw()
	pass

func _ready():
	%settings_menu.visible
	pass

func player_direction()->Vector2:
	move_vec = Vector2()
	# movement direction
	# var direction_3d := Vector3.ZERO
	 
			
	if Input.is_action_pressed("move_up"): move_vec.y -= 1
	if Input.is_action_pressed("move_down"): move_vec.y += 1
	if Input.is_action_pressed("move_left"): move_vec.x -= 1
	if Input.is_action_pressed("move_right"): move_vec.x += 1
	move_vec = move_vec.normalized()
	return move_vec

@onready var look_vec:Vector2 = get_global_mouse_position() - global_position
@onready var rotation_equation:float = lerp_angle(global_rotation,atan2(look_vec.y, look_vec.x) ,0.5)
@onready var rotation_weight:float =0.5
func calculate_player_rotation(weight:float=0.5)->float:
	look_vec = get_global_mouse_position() - global_position
	rotation_equation= lerp_angle(global_rotation,atan2(look_vec.y, look_vec.x) ,weight)
	return rotation_equation

func _input(event):
	if Input.is_action_pressed("settings"):
		print("settings")
		%settings_menu.visible = true
	pass

@onready var game_config_name := "player1"
func save_game_settings()->void:
	game_config.set_value(game_config_name, "audio_settings", %settings_menu.sound_buses)
	game_config.set_value(game_config_name, "video_settings", %settings_menu.video_setting_properties)
	var input_actions:Dictionary
	var actions := InputMap.get_actions()
	actions.sort()
	for action in actions:
		input_actions[action] = InputMap.action_get_events(action)
	game_config.set_value(game_config_name, "key_bindings", input_actions)
	game_config.save(game_config_path)
	# print_debug("saved when cloded")


# @onready var saved_game:SavedGame = SavedGame.new()
# @onready var loaded_game:SavedGame = load(save_game_filepath) as SavedGame
# func save_player_save()->void:
	# saved_game.gold_counter = gold_counter
	# ResourceSaver.save(saved_game,save_game_filepath)

# func load_player_save()->void:
# 	if loaded_game!=null:
# 		if loaded_game.gold_counter > 0:
# 			gold_counter = loaded_game.gold_counter
# 		game_save_loaded.emit()


func _draw() -> void:
	var local_pos = (resources.local_to_map(get_global_mouse_position()))
	draw_string(ThemeDB.fallback_font,local_pos,str(local_pos))
