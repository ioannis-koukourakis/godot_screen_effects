class_name cMap extends Node

#-------------------------------------------------------

var mlRadialBlurInstanceID: int = -1;
var mInfoLabel: RichTextLabel;

#-------------------------------------------------------

func _ready():
	#########################
	# Create a new Label to show the controls.
	mInfoLabel = RichTextLabel.new();
	mInfoLabel.bbcode_enabled = true;
	mInfoLabel.anchor_right = 1.0;
	mInfoLabel.anchor_bottom = 0.5;
	mInfoLabel.text = "[color=green]Controls[/color]
		Add Radial Blur instance: [color=light_green]Press 1[/color]
		Add Camera FOV Shake instance: [color=light_green]Press 2[/color]
		Add Screen Shake instance: [color=light_green]Press 3[/color]
		Add Camera FOV Fade instance: [color=light_green]Press 4[/color]
		Add Screen Blur instance: [color=light_green]Press 5[/color]
		Add Screen Color Fade instance: [color=light_green]Press 6[/color]
		Add indefinite Radial Blur instance: [color=light_green]Press 7[/color]
		Modify indefinite Radial Blur instance amount: [color=light_green]Press 8[/color]
		Remove indefinite Radial Blur instance (fade out): [color=light_green]Press 9[/color]
		Toggle Motion Blur on/off: [color=light_green]Press 0[/color]
		Rotate Camera Left (Motion Blur preview): [color=light_green]Press Left Arrow[/color]
		Rotate Camera Right (Motion Blur preview): [color=light_green]Press Right Arrow[/color]
		";
	mInfoLabel.position = Vector2(10, 10);
	mInfoLabel.add_theme_color_override("font_color", Color(1, 1, 1));
	add_child(mInfoLabel);

#-------------------------------------------------------

func _input(aEvent: InputEvent) -> void:
	if (aEvent is InputEventKey && aEvent.pressed && !aEvent.echo):
		var lKeycode: int = aEvent.get_physical_keycode_with_modifiers();
		
		################################
		# Add Radial blur instance
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_1):
			ScreenEffects.AddRadialBlur(1.25, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add FOV shake instance
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_2):
			ScreenEffects.AddFovShake(5.0, 2.0, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen shake instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_3):
			ScreenEffects.AddScreenShake(0.5, 2.0, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add fov fade instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_4):
			ScreenEffects.AddFovFade(0.8, 1.0, 1.0, 2.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen blur instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_5):
			ScreenEffects.AddScreenBlur(0.25, 1.0, 1.0, 2.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen color fade instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_6):
			ScreenEffects.AddScreenFade(2.0, Color(1.0,0.0,0.0,0.8), Color(0.0,0.0,1.0,0.0));
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add a single radial blur instance and store its ID for later use.
		if (lKeycode == KEY_7):
			if (mlRadialBlurInstanceID == -1):
				mlRadialBlurInstanceID = ScreenEffects.AddRadialBlur(1.25, 1.0, -1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Use the radial blur ID we stored before to modify it
		if (lKeycode == KEY_8):
			if (mlRadialBlurInstanceID != -1):
				ScreenEffects.SetRadialBlurAmount(mlRadialBlurInstanceID, 0.5);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Use the radial blur ID we stored before to stop it.
		# Fades out based on the fade out value we initially set above.
		if (lKeycode == KEY_9):
			if (mlRadialBlurInstanceID != -1):
				ScreenEffects.StopRadialBlur(mlRadialBlurInstanceID);
				mlRadialBlurInstanceID = -1;
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Toggle motion blur
		if (lKeycode == KEY_0):
			ScreenEffects.SetMotionBlurActive(!ScreenEffects.GetMotionBlurActive());
			get_tree().get_root().set_input_as_handled();

#-------------------------------------------------------

func _physics_process(afTimeStep: float) -> void:
	if (is_instance_valid($Camera3D)==false): return;
	
	######################################
	# Rotate camera to showcase motion blur
	if (Input.is_action_pressed("ui_left")):
		$Camera3D.rotate_y(afTimeStep * 30);
	
	if (Input.is_action_pressed("ui_right")):
		$Camera3D.rotate_y(-afTimeStep * 30);

#-------------------------------------------------------
