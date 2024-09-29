class_name cMap extends Node

#-------------------------------------------------------

var mlRadialBlurInstanceID: int = -1;

#-------------------------------------------------------

func _input(aEvent: InputEvent) -> void:
	if (aEvent is InputEventKey && aEvent.pressed && !aEvent.echo):
		var lKeycode: int = aEvent.get_physical_keycode_with_modifiers();
		
		################################
		# Add Radial blur instance
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_1):
			EffectsHandler.AddRadialBlur(1.25, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add FOV shake instance
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_2):
			EffectsHandler.AddFovShake(0.5, 2.0, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen shake instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_3):
			EffectsHandler.AddScreenShake(0.5, 2.0, 1.0, 1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add fov fade instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_4):
			EffectsHandler.AddFovFade(0.8, 1.0, 1.0, 2.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen blur instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_5):
			EffectsHandler.AddScreenBlur(0.25, 1.0, 1.0, 2.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add screen color fade instance.
		# Multiple can be added at a time. An instance is added every time key is pressed.
		if (lKeycode == KEY_6):
			EffectsHandler.AddScreenFade(2.0, Color(0.0,0.1,0.2,0.5), Color(1.0,0,0,0));
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Add a single radial blur instance and store its ID for later use.
		if (lKeycode == KEY_7):
			if (mlRadialBlurInstanceID == -1):
				mlRadialBlurInstanceID = EffectsHandler.AddRadialBlur(1.25, 1.0, -1.0, 3.0);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Use the radial blur ID we stored before to modify it
		if (lKeycode == KEY_8):
			if (mlRadialBlurInstanceID != -1):
				EffectsHandler.SetRadialBlurAmount(mlRadialBlurInstanceID, 0.5);
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Use the radial blur ID we stored before to stop it.
		# Fades out based on the fade out value we initially set above.
		if (lKeycode == KEY_9):
			if (mlRadialBlurInstanceID != -1):
				EffectsHandler.StopRadialBlur(mlRadialBlurInstanceID);
				mlRadialBlurInstanceID = -1;
			get_tree().get_root().set_input_as_handled();
		
		################################
		# Toggle motion blur
		if (lKeycode == KEY_0):
			EffectsHandler.SetMotionBlurActive(!EffectsHandler.GetMotionBlurActive());
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
