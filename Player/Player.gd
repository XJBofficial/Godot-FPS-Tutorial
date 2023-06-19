extends KinematicBody


onready var CameraNode : Camera = get_node("Camera")
onready var Weapon : MeshInstance = get_node("Weapon")
onready var Target : Position3D = Weapon.get_node("Target")


var Speed = 0.1
var JumpForce = 3
var Sensitivity = 600.0
var Gravity = 0.1
var VerticalVelocity = 0
var Health = 100

var Type = "Player"

var Velocity = Vector3()
var Client : WebSocketClient



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_physics_process(self.name == Names.MyName)
	set_process_input(self.name == Names.MyName)



func _physics_process(delta):
	var Direction = Vector3()
	
	
	if Input.is_action_pressed("move_forward"):
		Direction.z -= Speed
	
	if Input.is_action_pressed("move_backward"):
		Direction.z += Speed
	
	if Input.is_action_pressed("move_right"):
		Direction.x += Speed
	
	if Input.is_action_pressed("move_left"):
		Direction.x -= Speed
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			VerticalVelocity = JumpForce
	
	
	# Rotate Weapon
	
	Weapon.rotation_degrees.x = CameraNode.rotation_degrees.x
	
	
	# Movement
	
	Direction = Direction.normalized()
	Velocity = Direction
	
	move_and_collide(Velocity.rotated(Vector3.UP, self.rotation.y))
	
	
	# Gravity
	
	VerticalVelocity -= Gravity
	move_and_slide(Vector3.UP * VerticalVelocity, Vector3.UP)
	
	
	# Send the packet of your position
	
	Client.get_peer(1).put_packet(JSON.print({
		"name": Names.MyName,
		"health": Health,
		"posX": self.translation.x,
		"posY": self.translation.y,
		"posZ": self.translation.z,
		"rotX": self.rotation.x,
		"rotY": self.rotation_degrees.y,
		"rotZ": self.rotation.z,
		"action": "Update"
	}).to_utf8())



func _input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x / Sensitivity)
		CameraNode.rotate_x(-event.relative.y / Sensitivity)
		CameraNode.rotation_degrees.x = clamp(CameraNode.rotation_degrees.x, -25, 25)
	
	
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	if Input.is_action_pressed("fire"):
		Shoot()



func Shoot():
	var Ammo = preload("res://Player/Ammo.tscn").instance()
	
	
	Ammo.translation = Target.global_transform.origin
	Ammo.rotation_degrees = Vector3(0, self.rotation.y, Weapon.rotation_degrees.z)
	Ammo.Shooter = self.name
	Ammo.Client = Client
	
	
	if self.name == Names.MyName: # Returns true if this player node is me
		Client.get_peer(1).put_packet(JSON.print({
			"name": Names.MyName,
			"action": "Shoot"
		}).to_utf8())
	
	
	self.get_parent().add_child(Ammo)



func Damaged(Amount : int):
	Health -= Amount
	print("Damaged, Health: " + str(Health))
	
	
	if Health <= 0:
		get_tree().quit()



func GetType():
	return Type
