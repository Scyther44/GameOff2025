class_name Arrow extends Bullet

var is_moving = true
var is_stuck_in_enemy = false
var enemy_body
var distance_vector #distance between bullet and enemies used to stick bullets/arrows into enemies
var velocity: Vector2 = Vector2.ZERO 

func _ready() -> void:
	speed = 700
	velocity = transform.x * speed
	
func _physics_process(delta):
	if is_moving:
		#position += transform.x * speed * delta
		velocity.y += 600 * delta
		position += velocity * delta
		rotation = velocity.angle()
	if is_stuck_in_enemy:
		if enemy_body!=null:
			position = enemy_body.global_position - distance_vector
			#print("enemy body pos:" + str(enemy_body.position))
			#print(position)
			#print(enemy_body.global_position.y)
		else:
			$Sprite2D.set_deferred("visible", false)
			await get_tree().create_timer(10).timeout
			queue_free()
	
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("head"):
		is_headshot = true
	print("boom headshot")
	
func _on_body_entered(body: Node2D) -> void:
	print("hello " + body.name)
	if body.is_in_group("player"):
		return
	is_moving = false
	distance_vector = body.global_position - global_position
	#print(distance_vector)
	print(body.name)
	if body.is_in_group("mobs"):
		is_stuck_in_enemy = true
		var knockback_dir = (body.global_position - global_position).normalized()
		enemy_body = body
		body.take_damage(damage, knockback_dir, is_headshot)
		$Particles.emitting = true
	#set_deferred("process_mode",PROCESS_MODE_DISABLED)
	$CollisionShape2D.set_deferred("disabled", true)
	#$Sprite2D.set_deferred("visible", false)
	#$Particles.emitting = true

func _on_particles_finished() -> void:
	#queue_free()
	pass
	
