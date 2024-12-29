@tool
extends TextureRect

@export var position_synchronizer: MultiplayerSynchronizer
@export var click_event: InputEventMouseButton
@export var relative_position: Vector2

func _enter_tree() -> void:
	var cstring := "#%s55" % name.substr(0, 6).rpad(6, "f")
	print(cstring)
	var color := Color.from_string(cstring, Color.AQUA)
	modulate = color 
	set_multiplayer_authority(name.to_int())
	#await ready
	#set_multiplayer_authority(multiplayer.get_unique_id())


# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	#if not multiplayer.get_peers().is_empty():
		#return
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		#print("Not my cursor")
		#print(multiplayer.get_peers())
		return
	
	if event is InputEventMouseMotion:
		position = event.position
		var screen_size: Vector2 = DisplayServer.window_get_size()
		
		relative_position = event.position/screen_size
		print(relative_position)
	elif event is InputEventMouseButton:
		click_event = event
		
func _process(delta: float) -> void:
	position = relative_position * (DisplayServer.window_get_size() as Vector2)
#func _process(delta: float) -> void:
	#print(get_multiplayer_authority())
	#if get_multiplayer_authority() != multiplayer.get_unique_id():
		#print("Not my cursor")
		#return
		#
	#position = get_global_mouse_position()
	
