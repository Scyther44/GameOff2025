class_name Bullet extends Area2D

@export var speed: float = 750.0
@export var damage: int = 10

var is_headshot = false
func _physics_process(delta):
	position += transform.x * speed * delta
	if position.x > 1300: #if bullet leaves the screen delete it to prevent killing off screen
		print("bullet_deleted")
		self.queue_free()

	
func _on_body_entered(body: Node2D) -> void:
	print("hello " + body.name)
	if !body.is_in_group("player"):
		if body.is_in_group("mobs"):
			var knockback_dir = (body.global_position - global_position).normalized()
			body.take_damage(damage, knockback_dir, is_headshot)
			$Particles.emitting = true
		#set_deferred("process_mode",PROCESS_MODE_DISABLED)
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite2D.set_deferred("visible", false)
		#$Particles.emitting = true

func _on_particles_finished() -> void:
	queue_free()
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("head"):
		is_headshot = true
