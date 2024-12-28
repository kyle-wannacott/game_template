extends Control


@onready var options:VBoxContainer = %options_vbox
@onready var audio_settings:Control = %audio_settings
@onready var video_settings:Control = %video_settings
@onready var control_settings:Control = %control_settings


@onready var sound_sliders :={
	AudioServer.get_bus_name(0):%master_sound_slider,
	AudioServer.get_bus_name(1):%sound_effects_slider,
	AudioServer.get_bus_name(2):%music_sound_slider,
}

@onready var sound_buses := {
	AudioServer.get_bus_name(0):1.0,
	AudioServer.get_bus_name(1):1.0,
	AudioServer.get_bus_name(2):1.0,
}

@onready var options_menu:={
	"video":%video_menu_button,
	"sound":%sound_menu_button,
	"resume":%resume_menu_button,
	"controls":%controls_menu_button,
}

@onready var video_setting_properties := {
	"fullscreen":false,
	# "window_size":Vector2,
	"vsync":true,
	"render_scale_3d":0.8,
	"render_mode":0,
	"texture_filtering_mode":0,
	"snap_pixels":false,
	"snap_transforms":false,
}


@onready var video_setting_checkboxes := {
	"fullscreen":%fullscreen_checkbox,
	"vsync":%vsync_checkbox,
	"snap_pixels":%snap_pixels_checkbox,
	"snap_transforms":%snap_transforms_checkbox,
}
@onready var render_scale_3d_slider :=%render_scale_3d_slider 
@onready var render_scale_mode :=%render_scale_mode 
@onready var texture_filtering_mode :=%texture_filtering_mode 

@onready var player := get_tree().get_first_node_in_group("player")

@onready var sound_back_button := %sound_back_button
@onready var video_back_button := %video_back_button
@onready var control_back_button := %control_back_button
@onready var reset_keybinds_button := %reset_keybinds_button

func load_game_settings()->void:
	var err :Error= player.game_config.load(player.game_config_path)
	if err != OK: print_debug("error loading game config: ",err)
	if player.game_config.get_value(player.game_config_name,"audio_settings"): player.settings_menu.sound_buses= player.game_config.get_value(player.game_config_name, "audio_settings")
	if player.game_config.get_value(player.game_config_name,"audio_settings"): player.settings_menu.video_setting_properties = player.game_config.get_value(player.game_config_name, "video_settings")
	if player.game_config.get_value(player.game_config_name,"key_bindings"):
		var key_bindings:Dictionary = player.game_config.get_value(player.game_config_name,"key_bindings")
		key_bindings.keys().sort()
		player.settings_menu.create_action_list(key_bindings)
	else:
		player.settings_menu.create_action_list();
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options_menu["video"].connect("pressed",_on_video_menu_button_pressed)
	options_menu["sound"].connect("pressed",_on_sound_menu_button_pressed)
	options_menu["resume"].connect("pressed",_on_resume_menu_button_pressed)
	options_menu["controls"].connect("pressed",_on_controls_button_pressed)


	options.visible =false
	audio_settings.visible=false
	video_settings.visible=false
	control_settings.visible=false
	await get_tree().create_timer(0.01).timeout
	# RenderingServer.viewport_set_default_canvas_item_texture_filter(
	print("load setting")
	load_game_settings()


	for video_setting:String in video_setting_checkboxes:
		video_setting_checkboxes[video_setting].button_pressed = video_setting_properties[video_setting]


	render_scale_3d_slider.set_value(video_setting_properties["render_scale_3d"])
	render_scale_mode.select(video_setting_properties["render_mode"])

	set_render_scale_3d(video_setting_properties["render_scale_3d"])
	set_render_mode(video_setting_properties["render_mode"])
	set_texture_filtering_mode(video_setting_properties["texture_filtering_mode"])
	_set_vsync(video_setting_properties["vsync"])
	_set_fullscreen(video_setting_properties["fullscreen"])
	_set_snap_pixels(video_setting_properties["snap_pixels"])
	_set_snap_transforms(video_setting_properties["snap_transforms"])

	video_setting_checkboxes["fullscreen"].connect("toggled",_set_fullscreen)
	video_setting_checkboxes["vsync"].connect("toggled",_set_vsync)
	video_setting_checkboxes["snap_pixels"].connect("toggled",_set_snap_pixels)
	video_setting_checkboxes["snap_transforms"].connect("toggled",_set_snap_transforms)

	for sound_bus_key:String in sound_sliders:
		sound_sliders[sound_bus_key].connect("value_changed",_on_volume_slider_changed.bind(sound_bus_key))
		sound_sliders[sound_bus_key].set_value(sound_buses[sound_bus_key])

	render_scale_3d_slider.connect("value_changed",set_render_scale_3d)

	render_scale_mode.connect("item_selected",set_render_mode)
	texture_filtering_mode.connect("item_selected",set_texture_filtering_mode)

	sound_back_button.connect("pressed",_back_to_settings)
	video_back_button.connect("pressed",_back_to_settings)
	control_back_button.connect("pressed",_back_to_settings)

	reset_keybinds_button.connect("pressed",_on_reset_keybinds)
	pass # Replace with function body.

func _set_fullscreen(toggle:bool)->void:
	if toggle: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		get_tree().root.get_window().size = DisplayServer.screen_get_size()
	video_setting_properties["fullscreen"] = toggle
	player.save_game_settings()

		# DisplayServer.centre(DisplayServer.WINDOW_MODE_WINDOWED)

func _set_vsync(toggle:bool)->void:
	if toggle: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	video_setting_properties["vsync"] = toggle
	player.save_game_settings()

func _set_snap_transforms(toggle:bool)->void:
	get_tree().root.get_viewport().snap_2d_transforms_to_pixel= toggle
	video_setting_properties["snap_transforms"] = toggle
	player.save_game_settings()

func _set_snap_pixels(toggle:bool)->void:
	get_tree().root.get_viewport().snap_2d_vertices_to_pixel= toggle
	video_setting_properties["snap_pixels"] = toggle
	player.save_game_settings()

@onready var viewports :=  get_tree().get_nodes_in_group("viewport")
func set_render_scale_3d(value:float)->void:
	viewports =  get_tree().get_nodes_in_group("viewport")
	for viewport in viewports:
		viewport.scaling_3d_scale=value
	%render_scale_label.text = "Render Scale: "+str(value)
	video_setting_properties["render_scale_3d"] = value
	player.save_game_settings()


func set_render_mode(value:int)->void:
	for viewport in viewports:
		viewport.scaling_3d_mode = value
	video_setting_properties["render_mode"] = value
	player.save_game_settings()

func set_texture_filtering_mode(value:int)->void:
	match value:
		0:
			get_tree().root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
		1:
			get_tree().root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
		2:
			get_tree().root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		3:
			get_tree().root.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	video_setting_properties["texture_filtering_mode"] = value
	player.save_game_settings()


func _on_sound_menu_button_pressed() -> void:
	audio_settings.visible = true
	video_settings.visible = false
	control_settings.visible = false
	options.visible = false
	pass # Replace with function body.

func _on_video_menu_button_pressed() -> void:
	video_settings.visible = true
	audio_settings.visible = false
	control_settings.visible = false
	options.visible = false
	pass # Replace with function body.

func _on_controls_button_pressed() -> void:
	control_settings.visible = true
	video_settings.visible = false
	audio_settings.visible = false
	options.visible = false
	pass # Replace with function body.

func _on_resume_menu_button_pressed() -> void:
	video_settings.visible = false
	audio_settings.visible = false
	control_settings.visible = false
	options.visible = false
	pass # Replace with function body.


# func set_volume():master_bus.set_bus_volume_db(linear_to_db())

func _on_volume_slider_changed(value:float,bus_name:String) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name),linear_to_db(value))
	sound_buses[bus_name] = value
	player.save_game_settings()
	pass # Replace with function body.

func _back_to_settings()->void:
	options.visible=true
	audio_settings.visible=false
	video_settings.visible=false
	control_settings.visible=false

@onready var action_list := %action_list
@onready var input_button_scene = preload("res://player_settings/key_binding.tscn")

# input_actions 

# func create_action_list()->void:
# 	InputMap.load_from_project_settings()
# 	for item in	action_list.get_children():
# 		item.queue_free()
	
# 	for action in InputMap.get_actions():
# 		var button := input_button_scene.instantiate()
# 		var action_label := button.find_child("LabelAction")
# 		var input_label := button.find_child("LabelInput")

# 		if !action.contains("ui_"):
# 			action_label.text = action.capitalize()
# 			var events := InputMap.action_get_events(action)
# 			if events.size()>0:
# 				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
# 			else:
# 				input_label.text=""
# 			action_list.add_child(button)
# 			button.connect("pressed",_on_input_button_pressed.bind(button,action))
	# for action in InputMap

var is_remapping := false
var action_to_remap = null
var remapping_button = null
func _on_input_button_pressed(button:Button,action:StringName)->void:
	if !is_remapping:
		is_remapping=true
		action_to_remap=action
		remapping_button=button
		button.find_child("LabelInput").text ="Press Key to Bind..."

func _input(event:InputEvent)->void:
	if is_remapping:
		remap_button(event,action_to_remap,remapping_button)

	if Input.is_action_just_pressed("settings"):
		audio_settings.visible = false
		video_settings.visible = false
		control_settings.visible = false
		options.visible = !options.visible
		options.get_node("%options_vbox/%resume_menu_button").grab_focus()

func update_action_list(button:Button,event:InputEvent)->void:
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_keybinds()->void:
	print_debug("reset by misteak")
	create_action_list()
	player.save_game_settings()


func remap_button(event,action_to_remap=null,remapping_button=null)->void:
	if (event is InputEventKey || (event is InputEventMouseButton && event.pressed)
	):
		InputMap.action_erase_events(action_to_remap)
		InputMap.action_add_event(action_to_remap,event)
		update_action_list(remapping_button,event)
		is_remapping=false
		action_to_remap=null
		remapping_button=null
		player.save_game_settings()


func create_action_list(loaded_actions:Dictionary={})->void:
	if !loaded_actions:
		InputMap.load_from_project_settings()

	for item in	action_list.get_children():
		item.queue_free()
	var actions
	if loaded_actions:actions=loaded_actions; 
	else:actions= InputMap.get_actions()
	actions.sort()

	for action:String in actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")

		if !action.contains("ui_"):
			action_label.text = action.capitalize()+": "
			var events
			if loaded_actions: events = actions[action]

			else: events = InputMap.action_get_events(action)
			if events.size()>0:
				input_label.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_label.text=""
			action_list.add_child(button)
			button.connect("pressed",_on_input_button_pressed.bind(button,action))
			if loaded_actions:
				InputMap.action_erase_events(action)
				for event in actions[action]:
					InputMap.action_add_event(action,event)
