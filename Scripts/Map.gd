extends Node


onready var Spawn : Position3D = get_node("Spawn")

var Client = WebSocketClient.new()
var Server = "ws://127.0.0.1:5000"



func _ready():
	Client.connect("connection_established", self, "Connected")
	Client.connect("connection_closed", self, "Disconnect")
	Client.connect("data_received", self, "PacketReceived")
	
	
	set_process(true)
	
	var Error = Client.connect_to_url(Server)
	if Error == OK:
		print("Connecting...")
	else:
		print("Failed to connect.")
		set_process(false)
	
	
	NetPacketsManager.Game = self



func _process(delta):
	# Polling...
	Client.poll()



func Connected(protocol):
	print("Connected!")
	set_process(true)
	
	
	randomize()
	var Id = "Player " + str(randi() % 99999999999999)
	Id = Id.replace(".", "")
	Names.MyName = Id
	
	Spawn(Names.MyName)



func Disconnect():
	print("Disconnected.")



func Spawn(Id):
	var Player = preload("res://Player/Player.tscn").instance()
	
	
	Player.set_name(Id)
	Player.set_translation(Spawn.translation)
	Player.set_rotation_degrees(Spawn.rotation_degrees)
	
	Player.Client = Client
	
	
	if Id == Names.MyName:
		Client.get_peer(1).put_packet(JSON.print({
			"name": Id,
			"action": "Spawn"
		}).to_utf8())
	
	
	self.add_child(Player)



func PacketReceived():
	var Packet = JSON.parse(Client.get_peer(1).get_packet().get_string_from_utf8()).result as Dictionary
	NetPacketsManager.ManagePacket(Packet)
