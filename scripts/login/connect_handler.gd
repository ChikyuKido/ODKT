extends Node

@onready var url_edit = $"../UrlEdit"
@onready var error_text = $"../ErrorText"
@onready var username_edit = $"../UsernameEdit"
@onready var password_edit = $"../PasswordEdit"
@onready var http = $"../../../HTTPRequest"

	
func _on_connect():
	print("Connected to server")
	get_tree().change_scene_to_file("res://scene/title_screen.tscn")
func _on_connection_close(code,reason):
	error_text.set_visible(true)
	error_text.clear()
	error_text.push_color(Color("red"))
	error_text.add_text(str(code)+": Failed to connect because: "+reason)
	print("Failed to connect")
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	error_text.set_visible(true)
	error_text.clear()
	if response_code != 200:
		error_text.push_color(Color("red"))
		error_text.add_text(str(response_code)+": Failed to login: "+json["error"])
	else:
		error_text.push_color(Color("green"))
		error_text.add_text("Sucessfully logged in. Now connecting")
		var ws_url = "ws://"+url_edit.text+"/ws"
		print(WebsocketClient.connect_to_url(ws_url,json["token"]))
func _ready() -> void:
	WebsocketClient.connected_to_server.connect(_on_connect)
	WebsocketClient.connection_closed.connect(_on_connection_close)
	http.request_completed.connect(_on_request_completed)
	
func _process(delta: float) -> void:
	pass

func login():
	var login_url = "http://"+url_edit.text+"/api/v1/auth/login"
	var username = username_edit.text
	var password = password_edit.text
	var body = JSON.new().stringify({"username":username,"password": password})
	var headers = ["Content-Type: application/json"]
	http.request(login_url,headers,HTTPClient.METHOD_POST,body)
