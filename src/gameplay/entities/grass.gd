extends Area2D

@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var sprite : AnimatedSprite2D = $Sprite2D

func _on_area_entered(_body):
	sprite.play("rustle")
