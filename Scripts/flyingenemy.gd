extends CharacterBody2D

@export var max_health: int = 200
@export var speed: float = 100.0
@export var knockback_strength: float = 250.0
@export var gravity = 0
signal enemy_died
var health: int
var is_knocked_back: bool = false
var headshot_multiplier = 2
func _ready():
	health = max_health

func _physics_process(delta: float) -> void:
	if is_knocked_back:
		# Apply friction to knockback velocity
		velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
	else:
		# Move toward the player (assuming player is at x=0)
		velocity = Vector2(-speed, 0)
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0


	move_and_slide()

	# Stop knockback once slow enough
	if is_knocked_back and velocity.length() < 10:
		is_knocked_back = false


func take_damage(amount: int, knockback_dir: Vector2, is_headshot: bool) -> void:
	if is_headshot:
		health -= amount * headshot_multiplier
	else:
		health -= amount
	is_knocked_back = true
	velocity = knockback_dir.normalized() * knockback_strength

	# Flash red or play a hit animation here if you want
	modulate = Color(0.5, 0.5, 1)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die() -> void:
	emit_signal("enemy_died")
	queue_free()
	
