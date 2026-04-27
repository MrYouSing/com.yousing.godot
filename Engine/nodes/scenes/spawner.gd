class_name Spawner extends Runnable

@export_group("Spawn")
@export var source:Variant
@export var root:Node
@export var parent:Node

signal created()

var type:int=-1
var index:int
var prefab:Node
var actor:Node
var actors:Array[Node]

func run()->void:
	actor=null
	if type<0:_prepared()
	if Application.get_frames()==0:_created.call_deferred()
	else:_created()

func _prepared()->void:
	var c:int=get_meta(&"Capacity",0)
	if source==null:
		return
	elif source is Resource:
		if c>0:
			type=2;actors.resize(c)
			for i in c:
				actor=source.instantiate()
				GodotExtension.set_enabled(actor,false)
				actors[i]=actor
		else:
			type=0;prefab=Stage.instance.unpack(source)
	elif source is Node:
		type=1;prefab=source
		#
		if c>0:
			type=2;actors.resize(c)
			for i in c:
				actor=prefab.duplicate()
				GodotExtension.set_enabled(actor,false)
				actors[i]=actor

func _created()->void:
	match type:
		0:# Prefab
			if root!=null:actor=Stage.instance.spawn(prefab,parent,root.global_transform,true)
			else:actor=Stage.instance.spawn(prefab,parent,null)
		1:# Node
			actor=prefab.duplicate();GodotExtension.add_node(actor,parent,false)
			if root!=null:actor.global_transform=root.global_transform
		2:# Pool
			#GodotExtension.set_enabled(actor,false)
			actor=actors[index];index=(index+1)%actors.size()
			GodotExtension.move_node(actor,-1)
			if root!=null:actor.global_transform=root.global_transform
			GodotExtension.set_enabled(actor,true)
	if actor!=null:created.emit()

# For other systems.

func _on_animate(...a:Array)->void:
	created.connect(_do_animate.bind(a),CONNECT_ONE_SHOT)
	run()

func _do_animate(a:Array)->void:
	if actor!=null and actor.has_method(&"_on_animate"):
		actor.callv(&"_on_animate",a)
