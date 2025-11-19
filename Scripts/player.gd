extends CharacterBody2D

@onready var shoot_timer = $FiringTimer
@export var health = 100
@export var can_shoot: bool = true
@export var bullet_scene := preload("res://Scenes/bullet.tscn")
var gun_safety_on = false
var is_shooting: bool = false
var last_rotation_vector: Vector2 = Vector2.UP
#var bullet_scene = preload("res://bullet.tscn")
var bullet_references: Array[Bullet]
const HALF_PI := PI * 0.5
var bow_fire_rate = 1 ## The duration of the cooldown between firing projectiles.
var rifle_fire_rate = 1
var cannon_fire_rate = 1
var bouncing_betty_fire_rate = 1
var rifle_unlocked = false
var cannon_unlocked = false
var has_bow_multishot_1 = false
var has_bow_multishot_2 = false
var multishot_count = 0
var has_rifle_multishot = false
var has_cannon_multishot = false
var has_betty_multishot = false
var arrow_damage = 10
var bullet_damage = 25
var cannon_ball_damage = 100
signal weapon_changed
signal weapon_bought
enum Weapons {BOW, RIFLE, CANNON}
var equipped_weapon = Weapons.BOW
var top_sprite = Sprite2D
var top_sprite_bow_image = preload("res://Assets/playertopbownew.png")
var top_sprite_rifle_image = preload("res://Assets/playertoprifle.png")
func _ready() -> void:
	shoot_timer.wait_time = bow_fire_rate
	top_sprite = $Sprite2D
	#shoot_timer.connect("timeout", self._on_shoot_timer_timeout)
	
func _process(_delta: float) -> void:
	if is_shooting and can_shoot and !gun_safety_on:
		shoot()
		can_shoot = false
		shoot_timer.start()

	# --- Aim clamping ---
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dir: Vector2 = mouse_pos - global_position

	# if mouse exactly on player, don't change rotation
	if dir == Vector2.ZERO:
		return

	# get raw angle (in radians)
	var raw_angle: float = dir.angle()

	# normalize into -PI..PI to avoid wrap issues
	raw_angle = wrapf(raw_angle, -PI, PI)

	# clamp to forward arc (±90°)
	var clamped_angle: float = clamp(raw_angle, -HALF_PI, HALF_PI)

	$Sprite2D.rotation = clamped_angle
	#$Marker2D.rotation = clamped_angle
	#printt("raw:", raw_angle, "clamped:", clamped_angle)
	
func _input(event: InputEvent) -> void:
	if event.is_action("shoot"):
		is_shooting = event.is_pressed()
	#elif event.is_action("weaponkey4"):
	#	shoot_timer.wait_time = rifle_fire_rate
	#	bullet_scene = preload("res://betty.tscn")
	elif event.is_action("weaponkey3"):
		if cannon_unlocked:
			emit_signal("weapon_changed", 2)
			shoot_timer.wait_time = cannon_fire_rate
			bullet_scene = preload("res://Scenes/cannonball.tscn")
			equipped_weapon = Weapons.CANNON
	elif event.is_action("weaponkey2"):
		if rifle_unlocked:
			emit_signal("weapon_changed", 1)
			shoot_timer.wait_time = rifle_fire_rate
			bullet_scene = preload("res://Scenes/bullet.tscn")
			equipped_weapon = Weapons.RIFLE
			top_sprite.texture = top_sprite_rifle_image
	elif event.is_action("weaponkey1"):
		emit_signal("weapon_changed", 0)
		shoot_timer.wait_time = bow_fire_rate
		bullet_scene = preload("res://Scenes/arrow.tscn")
		equipped_weapon = Weapons.BOW
		top_sprite.texture = top_sprite_bow_image
		
func shoot():
	match equipped_weapon:
		Weapons.BOW:
			var b = bullet_scene.instantiate()
			b.damage = arrow_damage
			owner.add_child(b)
			bullet_references.push_back(b)
				
			#b.transform = $Sprite2D/Marker2D.global_transform
			var spawn_pos: Vector2 = $Sprite2D/Marker2D.global_position
			var aim_dir: Vector2 = Vector2.RIGHT.rotated($Sprite2D.rotation)
			# Set bullet position
			b.global_position = spawn_pos
					
			# Check if bullet has "velocity" property (e.g. arrow)
			if "velocity" in b:
				b.rotation = aim_dir.angle()
				b.velocity = aim_dir * b.speed
								
			if(has_bow_multishot_1):
				var second_b = bullet_scene.instantiate()
				second_b.damage = arrow_damage
				owner.add_child(second_b)
				bullet_references.push_back(second_b)
				#b.transform = $Sprite2D/Marker2D.global_transform
				var second_aim_dir: Vector2 = Vector2.RIGHT.rotated($Sprite2D.rotation) + Vector2.from_angle(25)
				print("aim_dir = " + str(second_aim_dir))
				# Set bullet position
				second_b.global_position = spawn_pos
					
				# Check if bullet has "velocity" property (e.g. arrow)
				if "velocity" in second_b:
					second_b.rotation = second_aim_dir.angle()
					second_b.velocity = second_aim_dir * second_b.speed / 2
					
			if(has_bow_multishot_2):
				var third_b = bullet_scene.instantiate()
				third_b.damage = arrow_damage
				owner.add_child(third_b)
				bullet_references.push_back(third_b)
				#b.transform = $Sprite2D/Marker2D.global_transform
				var third_aim_dir: Vector2 = Vector2.RIGHT.rotated($Sprite2D.rotation) + Vector2.from_angle(-45)
				print("aim_dir = " + str(third_aim_dir))
				# Set bullet position
				third_b.global_position = spawn_pos
					
				# Check if bullet has "velocity" property (e.g. arrow)
				if "velocity" in third_b:
					third_b.rotation = third_aim_dir.angle()
					third_b.velocity = third_aim_dir * third_b.speed / 2
					
		Weapons.RIFLE:
			var b = bullet_scene.instantiate()
			b.damage = bullet_damage
			owner.add_child(b)
			bullet_references.push_back(b)
				
			#b.transform = $Sprite2D/Marker2D.global_transform
			var spawn_pos: Vector2 = $Sprite2D/Marker2D.global_position
			var aim_dir: Vector2 = Vector2.RIGHT.rotated($Sprite2D.rotation)
			# Set bullet position
			b.global_position = spawn_pos
			b.transform = $Sprite2D/Marker2D.global_transform
			
		Weapons.CANNON:
			var b = bullet_scene.instantiate()
			b.damage = cannon_ball_damage
			owner.add_child(b)
			bullet_references.push_back(b)
				
			#b.transform = $Sprite2D/Marker2D.global_transform
			var spawn_pos: Vector2 = $Sprite2D/Marker2D.global_position
			var aim_dir: Vector2 = Vector2.RIGHT.rotated($Sprite2D.rotation)
			# Set bullet position
			b.global_position = spawn_pos
			b.transform = $Sprite2D/Marker2D.global_transform
			
func _on_firing_timer_timeout() -> void:
	# Reset shooting ability after the timer finishes
	can_shoot = true


func _on_main_shop_phase() -> void:
	gun_safety_on = true
	for bullet in bullet_references:
		if(bullet != null):
			bullet.queue_free()
	bullet_references.clear()


func _on_shop_ui_shop_closed() -> void:
	gun_safety_on = false

# Apply corresponding changes when upgrades are purchased
func _on_shop_ui_upgrade_purchased(upgrade_id: String) -> void:
	if (upgrade_id == "bow_fire_rate"):
		bow_fire_rate -= min(bow_fire_rate - 0.1, 0.1)
		print("current bow fire rate:" + str(bow_fire_rate))
		if equipped_weapon == Weapons.BOW:
			shoot_timer.wait_time = bow_fire_rate
	elif (upgrade_id == "buy_rifle"):
		rifle_unlocked = true
		emit_signal("weapon_bought", "rifle")
	elif (upgrade_id == "buy_cannon"):
		cannon_unlocked = true
		emit_signal("weapon_bought", "cannon")
	elif (upgrade_id == "rifle_fire_rate"):
		rifle_fire_rate -= min(rifle_fire_rate - 0.1, 0.1)
		print("current rifle fire rate:" + str(rifle_fire_rate))
		if equipped_weapon == Weapons.RIFLE:
			shoot_timer.wait_time = rifle_fire_rate
	elif (upgrade_id == "bow_multishot"):
		if multishot_count == 0:
			has_bow_multishot_1 = true
			multishot_count += 1
		else:
			has_bow_multishot_2 = true
	elif (upgrade_id == "bow_damage"):
		arrow_damage += arrow_damage
		print("arrow damage up = " + str(arrow_damage))
	elif (upgrade_id == "rifle_damage"):
		bullet_damage += bullet_damage
		print("bullet damage up = " + str(bullet_damage))
	elif (upgrade_id == "cannon_ball_damage"):
		cannon_ball_damage += cannon_ball_damage
		print("cannonball damage up = " + str(cannon_ball_damage))
		
