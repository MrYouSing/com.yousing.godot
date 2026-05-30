class_name Hitbox extends Node

static var current:Hitbox

@export_group("Hitbox")
@export var unit:Unit
@export var defense:float

signal on_damage(f:float)

var context:Object
var player:Player:
	get():return null if unit==null else unit.player

func get_center()->Vector3:
	var n:Node=get_node_or_null(^"Shape")
	if n==null:n=self
	return GodotExtension.get_global_position(n)

func set_enabled(b:bool)->void:
	PhysicsExtension.set_enabled(self,b)

func _on_damage(f:float)->void:
	var tmp:Hitbox=current;current=self
	on_damage.emit(f)
	unit._on_damage(f)
	current=tmp
