extends Node

enum GamePhase { SHOP, WAVE }

@export var enemy_scene: PackedScene
@export var flying_enemy_scene: PackedScene
@export var player: NodePath
@export var enemy_container: NodePath
@export var flying_enemy_container: NodePath 
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

func _ready():
	player_ref = get_node(player)
	enemy_parent = get_node(enemy_container)
	flying_enemy_parent = get_node(flying_enemy_container)
	start_shop_phase()


func start_wave_phase():
	current_phase = GamePhase.WAVE
	wave_number += 1
	print("=== Starting Wave", wave_number, "===")
	spawn_wave(wave_number)

func start_shop_phase():
	current_phase = GamePhase.SHOP
	emit_signal("shop_phase")
	print("=== Shop Phase ===")
	show_shop_ui()

func spawn_wave(wave_num: int):
	var enemy_count = base_enemy_count + wave_num * 5
	var flying_enemy_count =  wave_num % 3
	var enemy_health = base_enemy_health + wave_num * 10
	var enemy_speed = base_enemy_speed + wave_num * 5

	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		enemy.max_health = enemy_health
		enemy.speed = enemy_speed
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		enemy_parent.add_child(enemy)
		active_enemies += 1

		# spawn delay between enemies
		await get_tree().create_timer(0.4).timeout
		
	for i in range(flying_enemy_count):
		var enemy = flying_enemy_scene.instantiate()
		enemy.max_health = enemy_health
		enemy.speed = enemy_speed
		enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
		flying_enemy_parent.add_child(enemy)
		active_enemies += 1

		# spawn delay between enemies
		await get_tree().create_timer(0.4).timeout


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
		active_enemies -= 1
		if active_enemies <= 0 and current_phase == GamePhase.WAVE:
			print("Wave cleared!")
			start_shop_phase()
