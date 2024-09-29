@tool
class_name cScreenEffectsPlugin extends EditorPlugin

#-------------------------------------------------------

func _enter_tree():
	add_autoload_singleton("ScreenEffects", "res://addons/screen_effects/scripts/effects_handler.gd");
	print("[ScreenEffects] plugin activated.");

#-------------------------------------------------------

func _exit_tree():
	remove_autoload_singleton("ScreenEffects");

#-------------------------------------------------------
