extends Node

enum GamePhase { SHOP, WAVE }

@export var enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene
@export var jetpack_enemy_scene: PackedScene
@export var player: NodePath
@export var enemy_container: NodePath
@export var flying_enemy_container: NodePath 
@export var jetpack_enemy_container: NodePath 
@export var shop: Control
@export var hud: Control

@export var base_enemy_count: int = 5
@export var base_enemy_health: int = 10
@export var base_enemy_speed: float = 50.0

var wave_number: int = 0
var gold: int = 0 # players money during waves
var current_phase: GamePhase = GamePhase.SHOP
var active_enemies: int = 0
signal shop_phase

var player_ref: Node
var enemy_parent: Node
var flying_enemy_parent: Node
var jetpack_enemy_parent: Node

func _ready():
	player_ref = get_node(player)
	enemy_parent = get_node(enemy_container)
	flying_enemy_parent = get_node(flying_enemy_container)
	jetpack_enemy_parent = get_node(jetpack_enemy_container)
	start_shop_phase()


func start_wave_phase():
	current_phase = GamePhase.WAVE
	wave_number += 1
	print("=== Starting Wave", wave_number, "===")
	spawn_wave(wave_number)
	crossfade($ShopMusic, $WaveMusic)
	

func start_shop_phase():
	current_phase = GamePhase.SHOP
	emit_signal("shop_phase")
	print("=== Shop Phase ===")
	show_shop_ui()
	crossfade($WaveMusic, $ShopMusic)

func spawn_wave(wave_num: int):
	var enemy_count = base_enemy_count + wave_num * 5
	var flying_enemy_count =  wave_num / 3 + wave_num / 5
	var jetpack_enemy_count =  wave_num / 2 + wave_num / 5
	var enemy_health = base_enemy_health + wave_num * 10
	var enemy_speed = base_enemy_speed + wave_num * 5
	
	spawn_ground_enemies(enemy_count, enemy_health, enemy_speed)
	spawn_flying_enemies(flying_enemy_count, enemy_health, enemy_speed)
	spawn_jetpack_enemies(jetpack_enemy_count, enemy_health, enemy_speed)


func spawn_ground_enemies(count: int, health: int, speed: int) -> void:
	await get_tree().process_frame  # ensure async

	for i in range(count):
		var enemy = enemy_scene.instantiate()
		enemy.max_health = health
		enemy.speed = speed
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		enemy_parent.add_child(enemy)
		active_enemies += 1

		await get_tree().create_timer(0.7).timeout
		
func spawn_flying_enemies(count: int, health: int, speed: int) -> void:
	await get_tree().process_frame  # ensure async
	await get_tree().create_timer(10).timeout

	for i in range(count):
		var enemy = flying_enemy_scene.instantiate()
		enemy.max_health = health
		enemy.speed = speed * 1.5
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		flying_enemy_parent.add_child(enemy)
		active_enemies += 1
		await get_tree().create_timer(2).timeout
		
func spawn_jetpack_enemies(count: int, health: int, speed: int) -> void:
	await get_tree().process_frame  # ensure async
	await get_tree().create_timer(5).timeout

	for i in range(count):
		var enemy = jetpack_enemy_scene.instantiate()
		enemy.max_health = health
		enemy.speed = speed * 1.25
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		jetpack_enemy_parent.add_child(enemy)
		active_enemies += 1
		await get_tree().create_timer(1.5).timeout

func _on_enemy_died():
	active_enemies -= 1
	gold += 10
	hud.update_gold(shop.player_money + gold)

	if active_enemies <= 0 and current_phase == GamePhase.WAVE:
		print("Wave cleared!")
		start_shop_phase()
		
func show_shop_ui():
	hud.visible = false
	shop.night_num = wave_number
	shop.player_money += gold
	print("Shop open! Player gold:", gold)
	gold = 0 #reset it for next wave
	shop.z_index = 1
	var tween = get_tree().create_tween()
	tween.tween_property(shop, "modulate:a", 1, 3)
	await tween.finished
	
func _on_shop_ui_shop_closed() -> void:
	start_wave_phase()
	hud.visible = true
	
func _on_shop_ui_money_changed() -> void:
	hud.update_gold(shop.player_money + gold)


func _on_dmg_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.queue_free()
		player_ref.health -= 10
		hud.update_health(player_ref.health)
		
		print("health = " + str(player_ref.health))
		if player_ref.health <= 0:
			print("you died!!!!!!!!!")
			Savemanager.save_score(wave_number)
		active_enemies -= 1
		if active_enemies <= 0 and current_phase == GamePhase.WAVE:
			print("Wave cleared!")
			start_shop_phase()
			
func crossfade(from_player: AudioStreamPlayer, to_player: AudioStreamPlayer, duration := 1.5):
	# Start the new music if not already playing
	if not to_player.playing:
		to_player.play()
	var tween := create_tween()
	tween.tween_property(from_player, "volume_db", -30.0, duration) # fade out
	tween.parallel().tween_property(to_player, "volume_db", 0.0, duration) # fade in
	
	tween.finished.connect(func():
		from_player.stop()
		from_player.volume_db = -10 # reset for next time
		to_player.volume_db = -10
		)
	
