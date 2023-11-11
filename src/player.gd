extends CharacterBody2D
class_name Player

@export var MOVEMENT_SPEED: float = 200
@onready var camera := $Camera2D
@onready var sprite := $Sprite2D
@onready var shoot_raycast := $ShootRaycast
@onready var shoot_timer := $ShootRaycast/ShootTimer
@onready var label_name := $Label

@onready var shoot_particles = $ShootRaycast/ShootParticles
@onready var shoot_sfx = $ShootRaycast/ShootSFX

@rpc("call_local", "any_peer")
func set_label(label_text: String):
	label_name.text = label_text

func set_visibility(visiblity: bool):
	shoot_raycast.visible = visiblity
	label_name.visible = visiblity
	sprite.visible = visiblity

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
#    shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	camera.make_current()

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("shoot"): # and !shoot_raycast.enabled: #TODO SHOOT CD
		_play_shoot_effects.rpc()
		if shoot_raycast.is_colliding():
			print('colliding')
			var hit = shoot_raycast.get_collider()
			print(hit)

func _process(_delta):
	if not is_multiplayer_authority(): return
	shoot_raycast.look_at(get_global_mouse_position())

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	var input_vector: Vector2 = Input.get_vector(
		"move_left", "move_right","move_up", "move_down").normalized()
	velocity = input_vector * MOVEMENT_SPEED
	move_and_slide()

@rpc("call_local")
func _play_shoot_effects():
	shoot_particles.emitting = true
	shoot_sfx.play()


