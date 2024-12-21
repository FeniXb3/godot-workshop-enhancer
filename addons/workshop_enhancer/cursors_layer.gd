@tool
class_name CursorsLayer
extends CanvasLayer


@export var cursors_container: Control
@export var cursor_scene: PackedScene
@export var cursor_spawner: MultiplayerSpawner

func spawn_cursor(id: int) -> void:
	var cursor := (load(cursor_spawner.get_spawnable_scene(0)) as PackedScene).instantiate()
	#cursor.name = "cursor_%d" % id
	cursor.name = str(id)
	cursors_container.add_child(cursor, true)
	print("Cursor spawned for player %d" % id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Wait for signal bus autoload to be registered
	_on_ready.call_deferred()
	
func _on_ready() -> void:
	WorkshopEnhancerSignalBus.player_spawned.connect(spawn_cursor)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print("Spawned")
