extends KinematicBody


onready var Ray : RayCast = get_node("RayCast")


var Shooter = ""
var Speed = 0.3
var Damage = 10
var Velocity = Vector3()
var Client : WebSocketClient



func _physics_process(delta):
	var Direction = Vector3()
	
	
	Direction.z -= Speed
	Direction = Direction.normalized()
	Velocity = Direction
	
	
	move_and_collide(Velocity.rotated(Vector3.UP, self.rotation_degrees.y))
	
	
	# Ammo found a target
	
	if Ray.is_colliding():
		if Ray.get_collider().has_method("GetType"):
			var Collider = Ray.get_collider()
			
			
			if Collider.GetType() == "Player":
				var Packet = {
					"name": Shooter,
					"victim": Collider.name,
					"action": "Damaged"
				}
				Client.get_peer(1).put_packet(JSON.print(Packet).to_utf8())
				
				
				set_physics_process(false)
				self.queue_free() # Delete your self
