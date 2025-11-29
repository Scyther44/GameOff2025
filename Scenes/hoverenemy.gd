extends CharacterBody2D

@export var max_health: int = 200
@export var speed: float = 100.0
@export var knockback_strength: float = 250.0
@export var gravity = 0
signal enemy_died
var health: int
var is_knocked_back: bool = false
var headshot_multiplier = 2
var death_count = 0 #used to prevent enemies from dying twice
var hover_value := 0.0
var hover_direction := 1 
@export var hover_limit := 40
@export var hover_speed := 40.0

func _ready():
	health = max_health

func _physics_process(delta: float) -> void:
	if health <= 0 and death_count < 1:
		death_count += 1
		die()
	if is_knocked_back:
		# Apply friction to knockback velocity
		velocity = velocity.move_toward(Vector2.ZERO, 500 * delta)
	else:
		# Move toward the player (assuming player is at x=0)
		update_hover_height(delta)
		velocity = Vector2(-speed, 0)
		velocity.y = hover_value


	move_and_slide()

	# Stop knockback once slow enough
	if is_knocked_back and velocity.length() < 10:
		is_knocked_back = false


func update_hover_height(delta):
	hover_value += hover_direction * hover_speed * delta
	if hover_value >= hover_limit:
		hover_value = hover_limit
		hover_direction = -1
	elif hover_value <= -hover_limit:
		hover_value = -hover_limit
		hover_direction = 1
	
	

func take_damage(amount: int, knockback_dir: Vector2, is_headshot: bool) -> void:
	if is_headshot:
		health -= amount * headshot_multiplier
	else:
		health -= amount
	is_knocked_back = true
	velocity = knockback_dir.normalized() * knockback_strength

	# Flash red
	modulate = Color(0.5, 0.5, 1)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func die() -> void:
	queue_free()
	emit_signal("enemy_died")

	
