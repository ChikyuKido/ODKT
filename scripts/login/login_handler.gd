extends Node

@onready var url_edit = $"../UrlEdit"
@onready var error_text = $"../ErrorText"
@onready var username_edit = $"../UsernameEdit"
@onready var password_edit = $"../PasswordEdit"
@onready var http = $"../../../HTTPRequest"

	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	error_text.set_visible(true)
	error_text.clear()
	if response_code != 200:
		error_text.push_color(Color("red"))
		error_text.add_text(str(response_code)+": Failed to login: "+json["error"])
	else:
		error_text.push_color(Color("green"))
		error_text.add_text("Sucessfully logged in.")
		Globals.JWT_TOKEN = json["jwt"]
		Globals.URL = "http://"+url_edit.text
		get_tree().change_scene_to_file("res://scene/title_screen.tscn")
func _ready() -> void:
	http.request_completed.connect(_on_request_completed)
	
func login():
	var login_url = "http://"+url_edit.text+"/api/v1/auth/login"
	var username = username_edit.text
	var password = password_edit.text
	var body = JSON.new().stringify({"username":username,"password": password})
	var headers = ["Content-Type: application/json"]
	http.request(login_url,headers,HTTPClient.METHOD_POST,body)
