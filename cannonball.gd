extends Bullet
var hit_counter = 0
@export var hit_limit = 3

func _on_body_entered(body: Node2D) -> void:
	print("hello " + body.name)
	if !body.is_in_group("player"):
		if body.is_in_group("mobs"):
			hit_counter += 1
			var knockback_dir = (body.global_position - global_position).normalized()
			body.take_damage(damage, knockback_dir, is_headshot)
			$Particles.emitting = true
			if hit_counter >= hit_limit:
				$CollisionShape2D.set_deferred("disabled", true)
				$Sprite2D.set_deferred("visible", false)
		#set_deferred("process_mode",PROCESS_MODE_DISABLED)
		#$CollisionShape2D.set_deferred("disabled", true)
		#$Sprite2D.set_deferred("visible", false)
		#$Particles.emitting = true
