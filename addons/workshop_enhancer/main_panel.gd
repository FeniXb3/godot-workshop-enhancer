@tool
extends CenterContainer

@export var ipLineEdit: LineEdit
@export var portLineEdit: LineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_button_pressed() -> void:
	print("Hosting...")
	var peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(int(portLineEdit.text), 10)
	if error:
		printerr(error)
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.server_disconnected
	_on_player_connected(multiplayer.get_unique_id())
	
func _on_player_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	print("Player connected: %d" %id)
	WorkshopEnhancerSignalBus.player_spawned.emit(id)

func _on_connect_button_pressed() -> void:
	print("Connecting...")
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	var peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ipLineEdit.text, int(portLineEdit.text))
	if error:
		printerr(error)
	else:
		multiplayer.multiplayer_peer = peer

func _on_connected_to_server() -> void:
	_on_player_connected(multiplayer.get_unique_id())

func _on_stop_hosting_button_pressed() -> void:
	multiplayer.peer_connected.disconnect(_on_player_connected)
	multiplayer.multiplayer_peer.close()
