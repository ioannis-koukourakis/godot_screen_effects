class_name cMap extends Node

#-------------------------------------------------------

func _input(aEvent: InputEvent) -> void:
	if (aEvent is InputEventKey):
		var lKeycode: int = aEvent.get_physical_keycode_with_modifiers();
		if (lKeycode == KEY_1):
			EffectsHandler.AddFovShake(0.25, 2.0, 1.0, 1.0, 3.0);
		if (lKeycode == KEY_2):
			EffectsHandler.AddScreenShake(0.25, 2.0, 1.0, 1.0, 3.0);
		if (lKeycode == KEY_3):
			EffectsHandler.AddRadialBlur(1.0, 1.0, 1.0, 3.0);
		if (lKeycode == KEY_4):
			EffectsHandler.AddScreenBlur(0.25, 1.0, 1.0, 2.0);
		if (lKeycode == KEY_5):
			EffectsHandler.AddScreenFade(2.0, Color(0,0.1,0.2,1), Color(1.0,0,0,0));
		if (lKeycode == KEY_6):
			EffectsHandler.AddFovFade(0.8, 1.0, 1.0, 2.0);

#-------------------------------------------------------
