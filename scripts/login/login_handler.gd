extends Node

@onready var url_edit = $"../UrlEdit"
@onready var error_text = $"../ErrorText"

	
func _on_connect():
	print("Connected to server")
	get_tree().change_scene_to_file("res://scene/title_screen.tscn")
func _on_connection_close(code,reason):
	error_text.set_visible(true)
	error_text.clear()
	error_text.push_color(Color("red"))
	error_text.add_text(str(code)+": Failed to connect because: "+reason)
	print("Failed to connect")
	
func _ready() -> void:
	WebsocketClient.connected_to_server.connect(_on_connect)
	WebsocketClient.connection_closed.connect(_on_connection_close)

func _process(delta: float) -> void:
	pass

func login():
	print(WebsocketClient.connect_to_url(url_edit.text))
