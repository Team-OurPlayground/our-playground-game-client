extends Node

#IP 세팅
const HOST: String = "127.0.0.1"
const PORT: int = 6112
const RECONNECT_TIMEOUT: float = 3.0

const Client = preload("res://client.gd")

var _client: Client = Client.new()

#ProtoBuf 쓸수 있게 코드 포함
const MyProto = preload("res://protobuf.gd")



func _ready() -> void:
	get_child(0).connect("pressed",self,"_button_pressed")
	_client.connect("connected", self, "_handle_client_connected")
	_client.connect("disconnected", self, "_handle_client_disconnected")
	_client.connect("error", self, "_handle_client_error")
	_client.connect("data", self, "_handle_client_data")
	add_child(_client)
	_client.connect_to_host(HOST, PORT)
	

func _connect_after_timeout(timeout: float) -> void:
	yield(get_tree().create_timer(timeout), "timeout") # Delay for timeout
	_client.connect_to_host(HOST, PORT)

func _handle_client_connected() -> void:
	print("Client connected to server.")

func _handle_client_data(data: PoolByteArray) -> void:
	var a = MyProto.data.new()
	var result_code = a.from_bytes(data)
	if result_code == MyProto.PB_ERR.NO_ERRORS:
		print("OK")
	else:
		return
	print("Client data: ", a.get_pos_y())
	var message: PoolByteArray = [97, 99, 107] # Bytes for "ack" in ASCII
	_client.send(message)
	$Label.text= "POS_Y : " + a.get_pos_y() as String +"\n" + "POS_X : " + a.get_pos_x() as String

func _handle_client_disconnected() -> void:
	print("Client disconnected from server.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	print("Client error.")
	_connect_after_timeout(RECONNECT_TIMEOUT) # Try to reconnect after 3 seconds
	
func _button_pressed():
	var abc = MyProto.data.new()
	abc.set_pos_x($TextEdit.text as int)
	abc.set_pos_y($TextEdit2.text as int)
	abc.set_query($TextEdit3.text)
	var packed_bytes = abc.to_bytes()
	_client.send(packed_bytes)
