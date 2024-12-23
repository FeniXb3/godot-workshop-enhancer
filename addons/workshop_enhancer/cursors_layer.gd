@tool
class_name CursorsLayer
extends CanvasLayer

@export var cursors_container: Control
@export var cursor_scene: PackedScene
@export var cursor_spawner: MultiplayerSpawner
@export var spawned_cursors: Dictionary[int, TextureRect] = {}
@export var my_cursor: TextureRect

func spawn_cursor(id: int) -> void:
	if multiplayer == null:
		print("Multiplayer is null")
		return
		
	var cursor := (load(cursor_spawner.get_spawnable_scene(0)) as PackedScene).instantiate()
	cursor.name = str(id)
	cursors_container.add_child(cursor, true)
	spawned_cursors[id] = cursor
	print("Cursor spawned for player %d" % id)
	if id == multiplayer.get_unique_id():
		my_cursor = cursor
		print("My cursor setup")

func _ready() -> void:
	# Wait for signal bus autoload to be registered
	_on_ready.call_deferred()
	
func _on_ready() -> void:
	WorkshopEnhancerSignalBus.player_spawned.connect(spawn_cursor)
	WorkshopEnhancerSignalBus.player_despawned.connect(despawn_cursor)
	WorkshopEnhancerSignalBus.server_disconnection_attempt.connect(_on_disconnection_attempt)
	pass
	
func despawn_cursor(id: int) -> void:
	var cursor := spawned_cursors[id]
	if cursor:
		cursor.queue_free()
	
	spawned_cursors.erase(id)
	
func _on_disconnection_attempt() -> void:
	for id in spawned_cursors:
		spawned_cursors[id].queue_free()
		
	spawned_cursors.clear()

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("Spawned")
