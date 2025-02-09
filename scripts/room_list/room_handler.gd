extends Node

@onready var room_container = $Panel/Control/VBoxContainer/MarginContainer/ScrollContainer/Rooms
@onready var http = $HTTPRequest
var room_item = preload("res://prefabs/ui/room_item.tscn")

func _on_request_complete(result, response_code, headers, body):
	if response_code != 200:
		print("Could not load rooms. :"+body.get_string_from_utf8())
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	for room in json["rooms"]:
		_create_room(room)
	
func _ready() -> void:
	http.request_completed.connect(_on_request_complete)
	_search_rooms()

func _search_rooms():
	_clear_rooms()
	_get_rooms()
	
	
func _create_room(roomData):
	var room = room_item.instantiate()
	var room_parent = room.get_child(0).get_child(0).get_child(0)
	room_parent.get_child(1).get_child(0).text = roomData["name"]
	room_parent.get_child(1).get_child(1).get_child(0).text = "Owner: "+roomData["owner_name"] +"\nPlayers: "+str(roomData["players"])+"/"+str(roomData["max_players"])
	room_container.add_child(room)
	
func _get_rooms():
	var url = Globals.URL+"/api/v1/room/list"
	var headers = ["Authentication: Bearer "+ Globals.JWT_TOKEN]
	http.request(url,headers,HTTPClient.METHOD_GET)
	
func _clear_rooms():
	for i in range(room_container.get_child_count()):
		room_container.get_child(i).queue_free()
