## A helper singleton for game management.
class_name Game extends Node

const k_keyword:StringName=&"YouSing_Game"
static var s_create:Callable=func()->Object:
	var i:Game=Game.new();i.name=k_keyword
	GodotExtension.add_node(i,null,false);
	i._ready();return i

static var instance:Game:
	get:return Singleton.try_instance(k_keyword,s_create)
	set(x):Singleton.set_instance(k_keyword,x)

@export_group("Game")
@export var player:Player
@export var players:Array[Player]
@export var events:BaseMachine

func setup(p:Player)->void:
	if p==null:return
	#
	p.game=self

func teardown(p:Player)->void:
	if p==null:return
	#
	var tmp=Player.current;Player.current=p
	if p==player:invoke_event(&"on_game_over")
	else:invoke_event(&"on_player_defeat")
	Player.current=tmp
	#
	p.game=null

func invoke_event(e:StringName)->void:
	if events!=null:events._on_event(self,e)

func get_friendship(a:Player,b:Player)->int:
	if a==b:return 0
	return -1

func _on_attack(a:Attack,b:Hitbox)->void:
	if a==null or b==null:return
	# TODO: Override for attack bonuses.
	var d:float=a.attack
	if is_nan(b.defense):invoke_event(&"on_unit_parry");return
	elif b.defense<0.0:d*=-b.defense
	elif b.defense>=1.0:d=maxf(d-b.defense,1.0)
	else:d*=(1.0-b.defense)
	#
	invoke_event(&"on_unit_attack")
	b._on_damage(d)

func _on_mistake(a:Attack,b:Hitbox)->void:
	if a==null or b==null:return
	#
	invoke_event(&"on_unit_mistake")

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		for it in players:if it!=null and it!=player:setup(it)
		setup(player);if player==null:player=players[0]
