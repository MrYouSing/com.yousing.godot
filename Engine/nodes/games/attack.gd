class_name Attack extends Node

static var current:Attack

@export_group("Attack")
@export var unit:Unit
@export var detector:BaseDetector
@export var attack:float=10

var context:Object
var player:Player:
	get():return unit.player

func fire()->void:
	if detector!=null and detector.detect():
		if detector.targets.is_empty():hit(detector.target as Hitbox)
		else:for it in detector.targets:hit(it as Hitbox)

func hit(b:Hitbox)->void:
	if b==null:return
	var p:Player=player;if p==null:return
	var g:Game=p.game;if g==null:return
	#
	var box:Hitbox=Hitbox.current;Hitbox.current=b
	var tmp:Attack=current;current=self
	if g.get_friendship(p,b.player)<0:
		g._on_attack(self,b)
	else:
		g._on_mistake(self,b)
	current=tmp
	Hitbox.current=box
