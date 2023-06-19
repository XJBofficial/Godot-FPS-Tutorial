extends Node


var Game : Node = null



func ManagePacket(Packet : Dictionary):
	match Packet.action:
		"Spawn":
			if Packet.name != Names.MyName:
				if Game.get_node(Packet.name) == null:
					Game.Spawn(Packet.name)
		
		
		"Update":
			if Packet.name != Names.MyName:
				var Player = Game.get_node(Packet.name)
				
				
				# Check if this player exist
				
				if Player == null: # Player not exist
					var PlayerNode = preload("res://Player/Player.tscn").instance()
					
					PlayerNode.set_name(Packet.name)
					Game.add_child(PlayerNode)
					
					Player = Game.get_node(Packet.name)
				
				
				Player.Health = Packet.health
				Player.set_translation(Vector3(Packet.posX, Packet.posY, Packet.posZ))
				Player.set_rotation_degrees(Vector3(Packet.rotX, Packet.rotY, Packet.rotZ))
		
		
		"Damaged":
			if Packet.victim == Names.MyName:
				var MyPlayer = Game.get_node(Names.MyName)
				MyPlayer.Damaged(10)
		
		
		"Shoot":
			if Packet.name != Names.MyName:
				var Player = Game.get_node(Packet.name)
				Player.Shoot()
