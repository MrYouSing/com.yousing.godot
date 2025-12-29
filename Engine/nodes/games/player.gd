class_name Player extends Node

static var current:Player

@export_group("Player")
@export var game:Game
@export var unit:Unit
@export var units:Array[Unit]

func setup(u:Unit)->void:
	if u==null:return
	#
	u.player=self

func teardown(u:Unit)->void:
	if u==null:return
	var i:int=units.find(u);if i<0:return
	#
	if u==unit:unit=null
	u.player=null;units.remove_at(i)
	if units.is_empty():game.teardown(self)

func _ready()->void:
	for it in units:if it!=null and it!=unit:setup(it)
	setup(unit);if unit==null:unit=units[0]
