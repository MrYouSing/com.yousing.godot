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

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		pass
