extends Button

@export var item_name: String
@export var price: int
@export var upgrade_id: String

signal item_purchased(upgrade_id: String, cost: int)

func _ready():
	position += Vector2(randf_range(-5, 5), randf_range(-3, 3))
	rotation_degrees = randf_range(-4, 4)
	text = "" # we use labels for visuals
	$ItemName.text = item_name
	$Price.text = "$" + str(price)
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	emit_signal("item_purchased", upgrade_id, price)
		
func remove():
	self.queue_free()
