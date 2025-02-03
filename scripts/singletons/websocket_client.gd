class_name WebSocketClient
extends Node

var socket := WebSocketPeer.new()
var last_state := WebSocketPeer.STATE_CLOSED

signal connected_to_server()
signal connection_closed(int,String)
signal message_received(message: Variant)


func connect_to_url(url: String) -> int:
	if last_state != WebSocketPeer.STATE_CLOSED:
		return ERR_ALREADY_IN_USE
	socket.handshake_headers = ["authentication: Bearer token"]
	var err := socket.connect_to_url(url)
	if err != OK:
		return err
	return OK


func send(message: String) -> int:
	if last_state != WebSocketPeer.STATE_OPEN:
		return ERR_CANT_CONNECT
	if typeof(message) == TYPE_STRING:
		return socket.send_text(message)
	return socket.send(var_to_bytes(message))


func get_message() -> Variant:
	if socket.get_available_packet_count() < 1:
		return null
	var pkt := socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return bytes_to_var(pkt)


func close(code: int = 1000, reason: String = "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()

func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()

func get_socket() -> WebSocketPeer:
	return socket

func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()

	var state := socket.get_ready_state()

	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			connection_closed.emit(socket.get_close_code(),socket.get_close_reason())
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		message_received.emit(get_message())


func _process(_delta: float) -> void:
	poll()
