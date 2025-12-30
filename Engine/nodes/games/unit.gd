class_name Unit extends Node

static var current:Unit

@export_group("Unit")
@export var player:Player
@export var events:BaseMachine

@export var def_health:float=-1.0
@export var max_health:float=100.0
@export var hitboxes:Array[Hitbox]
@export var attacks:Array[Attack]

var health:float
var amount:float
signal on_born()
signal on_damage(f:float)
signal on_heal(f:float)
signal on_death()

#func setup_@(o:$)->void:if o!=null:o.unit=self
#func teardown_@(o:$)->void:if o!=null:o.unit=null
#func add_@(o:$)->void:
#	if o==null:return
#	var i:int=%.find(o);if i>=0:return
#	%.append(o);setup_@(o)
#func remove_@(o:$)->void:
#	if o==null:return
#	var i:int=%.find(o);if i<0:return
#	teardown_@(o);%.remove_at(i)
#func find_@(k:StringName)->$:
#	for it in %:if it!=null and it.name==k:return it
#	return null

func setup_hitbox(o:Hitbox)->void:if o!=null:o.unit=self
func teardown_hitbox(o:Hitbox)->void:if o!=null:o.unit=null
func add_hitbox(o:Hitbox)->void:
	if o==null:return
	var i:int=hitboxes.find(o);if i>=0:return
	hitboxes.append(o);setup_hitbox(o)
func remove_hitbox(o:Hitbox)->void:
	if o==null:return
	var i:int=hitboxes.find(o);if i<0:return
	teardown_hitbox(o);hitboxes.remove_at(i)
func find_hitbox(k:StringName)->Hitbox:
	for it in hitboxes:if it!=null and it.name==k:return it
	return null

func setup_attack(o:Attack)->void:if o!=null:o.unit=self
func teardown_attack(o:Attack)->void:if o!=null:o.unit=null
func add_attack(o:Attack)->void:
	if o==null:return
	var i:int=attacks.find(o);if i>=0:return
	attacks.append(o);setup_attack(o)
func remove_attack(o:Attack)->void:
	if o==null:return
	var i:int=attacks.find(o);if i<0:return
	teardown_attack(o);attacks.remove_at(i)
func find_attack(k:StringName)->Attack:
	for it in attacks:if it!=null and it.name==k:return it
	return null

func invoke_event(s:Signal,e:StringName,...a:Array)->void:
	var tmp:Unit=current;current=self
	s.emit(a)# Engine
	if events!=null:events._on_event(self,e)# User
	current=tmp

func _on_born()->void:
	var f:float=max_health
	if def_health>0.0:f=def_health
	elif def_health<0.0:f*=-def_health
	#
	health=f
	invoke_event(on_born,&"on_born")

func _on_damage(f:float)->void:
	if f<=0.0:return
	#
	var old:float=health
	health=clampf(health+f,0.0,max_health)
	amount=health-old
	#
	invoke_event(on_damage,&"on_damage",amount)
	if health<=0.0:_on_death()

func _on_heal(f:float)->void:
	if f<=0.0:return
	#
	var old:float=health
	health=clampf(health+f,0.0,max_health)
	amount=health-old
	#
	invoke_event(on_heal,&"on_heal",amount)

func _on_death()->void:
	invoke_event(on_death,&"on_death")
	health=0.0
	#
	player.teardown(self)

func _on_spawn()->void:
	if health<0.0:_on_born()

func _on_despawn()->void:
	health=-1.0

func _ready()->void:
	for it in attacks:setup_attack(it)
	for it in hitboxes:setup_hitbox(it)
	#
	if health==0.0:_on_born()
