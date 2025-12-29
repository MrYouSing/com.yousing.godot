class_name Unit extends Node

static var current:Unit

@export_group("Unit")
@export var player:Player
@export var events:BaseMachine

@export var health:float=-1.0
@export var max_health:float=100.0
@export var hitboxes:Array[Hitbox]
@export var attacks:Array[Attack]

var amount:float
signal on_damage(f:float)
signal on_heal(f:float)
signal on_death()

func invoke_event(s:Signal,e:StringName,...a:Array)->void:
	var tmp:Unit=current;current=self
	s.emit(a)# Engine
	if events!=null:events._on_event(self,e)# User
	current=tmp

func get_hitbox(k:StringName)->Hitbox:
	for it in hitboxes:if it!=null and it.name==k:return it
	return null

func get_attack(k:StringName)->Attack:
	for it in attacks:if it!=null and it.name==k:return it
	return null

func _on_damage(f:float)->void:
	var old:float=health
	health=clampf(health+f,0.0,max_health)
	amount=health-old
	#
	invoke_event(on_damage,&"on_damage",amount)
	if health<=0.0:_on_death()

func _on_heal(f:float)->void:
	var old:float=health
	health=clampf(health+f,0.0,max_health)
	amount=health-old
	#
	invoke_event(on_heal,&"on_heal",amount)

func _on_death()->void:
	invoke_event(on_death,&"on_death")
	#
	player.teardown(self)

func _ready()->void:
	for it in attacks:if it!=null:it.unit=self
	for it in hitboxes:if it!=null:it.unit=self
