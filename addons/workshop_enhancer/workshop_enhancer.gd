@tool
extends EditorPlugin


const MainPanel = preload("res://addons/workshop_enhancer/main_panel.tscn")
const CursorsLayer = preload("res://addons/workshop_enhancer/cursors_layer.tscn")
const SIGNAL_BUS_NAME = "WorkshopEnhancerSignalBus"
var main_panel_instance: CenterContainer
var mouse_position: Vector2
var base_control: Control
var cursors_layer: CanvasLayer

func _enter_tree() -> void:
	_setup_main_panel()
	_add_cursors_drawing_layer()
	print("enter tree")

func _setup_main_panel() -> void:
	main_panel_instance = MainPanel.instantiate() as CenterContainer
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)
	
func _has_main_screen() -> bool:
	return true
	
func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible

func _add_cursors_drawing_layer() -> void:
	base_control = EditorInterface.get_base_control()
	cursors_layer = CursorsLayer.instantiate() as CanvasLayer
	base_control.add_child(cursors_layer)

func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()
	
	if cursors_layer:
		cursors_layer.queue_free()

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
	
func _get_plugin_name() -> String:
	return "Workshop Enhancer"

func _enable_plugin() -> void:
	add_autoload_singleton(SIGNAL_BUS_NAME, "res://addons/workshop_enhancer/workshop_enhancer_signal_bus.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton(SIGNAL_BUS_NAME)
