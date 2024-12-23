@tool
extends CenterContainer

@export var ipLineEdit: LineEdit
@export var portLineEdit: LineEdit
@export var hostButton: Button
@export var stopHostButton: Button
@export var connectButton: Button
@export var disconnectButton: Button

var default_multiplayer_peer: OfflineMultiplayerPeer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Ready")
	default_multiplayer_peer = multiplayer.multiplayer_peer as OfflineMultiplayerPeer
	if default_multiplayer_peer == null:
		print("Default multiplayer peer was null, setting to new OfflineMultiplayerPeer")
		default_multiplayer_peer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = default_multiplayer_peer

func _on_host_button_pressed() -> void:
	if not _is_offline():
		var state := "hosting" if multiplayer.is_server() else "connected"
		print("Aleready %s" % state)
		return
	
	print("Hosting...")
	var peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(int(portLineEdit.text), 10)
	if error:
		printerr(error)
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	_on_player_connected.call_deferred(multiplayer.get_unique_id())
	
	hostButton.disabled = true
	stopHostButton.disabled = false
	connectButton.disabled = true
	disconnectButton.disabled = true
	
func _on_server_disconnected() -> void:
	_disconnect_client()
	
func _on_player_connected(id: int) -> void:
	if not multiplayer.is_server():
		return
	print("Player connected: %d" %id)
	WorkshopEnhancerSignalBus.player_spawned.emit(id)
	
func _on_player_disconnected(id: int) -> void:
	if not multiplayer.is_server():
		return
	
	print("Player disconnected: %d" %id)
	WorkshopEnhancerSignalBus.player_despawned.emit(id)

func _on_connect_button_pressed() -> void:
	if not _is_offline():
		var state := "hosting" if multiplayer.is_server() else "connected"
		print("Aleready %s" % state)
		return
	
	print("Connecting...")
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	var peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ipLineEdit.text, int(portLineEdit.text))
	if error:
		printerr(error)
	else:
		multiplayer.multiplayer_peer = peer

func _on_connected_to_server() -> void:
	_on_player_connected(multiplayer.get_unique_id())
	
	hostButton.disabled = true
	stopHostButton.disabled = true
	connectButton.disabled = true
	disconnectButton.disabled = false

func _on_stop_hosting_button_pressed() -> void:
	if _is_offline() or not multiplayer.is_server():
		print("Not hosting")
		return
	WorkshopEnhancerSignalBus.server_disconnection_attempt.emit()
	_stop.call_deferred()

func _stop() -> void:
	if multiplayer.peer_connected.is_connected(_on_player_connected):
		multiplayer.peer_connected.disconnect(_on_player_connected)
	
	if multiplayer.peer_disconnected.is_connected(_on_player_disconnected):
		multiplayer.peer_disconnected.disconnect(_on_player_disconnected)
	
	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		
	multiplayer.multiplayer_peer = default_multiplayer_peer
	
	hostButton.disabled = false
	stopHostButton.disabled = true
	connectButton.disabled = false
	disconnectButton.disabled = true

func _on_disconnect_button_pressed() -> void:
	if _is_offline():
		print("Not connected")
		return
	
	if multiplayer.is_server():
		var state := "hosting" if multiplayer.is_server() else "connected"
		print("Currently %s" % state)
		return
		
	_disconnect_client()
	
func _disconnect_client() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		
	if multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.disconnect(_on_connected_to_server)
	if multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.disconnect(_on_server_disconnected)
		
	multiplayer.multiplayer_peer = default_multiplayer_peer
	
	hostButton.disabled = false
	stopHostButton.disabled = true
	connectButton.disabled = false
	disconnectButton.disabled = true

func _is_offline() -> bool:
	return multiplayer.multiplayer_peer is OfflineMultiplayerPeer
