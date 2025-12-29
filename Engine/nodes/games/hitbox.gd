class_name Hitbox extends Node

static var current:Hitbox

@export_group("Hitbox")
@export var unit:Unit
@export var defense:float

signal on_damage(f:float)

var context:Object
var player:Player:
	get():return unit.player

func _on_damage(f:float)->void:
	var tmp:Hitbox=current;current=self
	on_damage.emit(f)
	unit._on_damage(f)
	current=tmp
