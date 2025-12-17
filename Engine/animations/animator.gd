## A wrapper class for animation system.
class_name Animator extends Node

const k_keywords:Array[StringName]=[
	&"type",&"name",
	&"duration",&"time",&"progress",
	&"current",&"next",&"path"
]
@export_group("Animation")
@export var player:AnimationPlayer
@export var tree:AnimationTree
@export var features:int=0
@export_group("State Machine")
@export var machine:BaseMachine
@export var layers:Array[StringName]
@export var parameters:Array[StringName]

var machines:Array[Object]
var info:Dictionary={}

# State Machine

func get_machine(l:int)->Object:
	if l>=0 and l<machines.size():
		return machines[l]
	else:
		return null

func is_fading(m:AnimationNodeStateMachinePlayback)->bool:
	if m!=null:
		return !m.get_fading_from_node().is_empty()
	return false

func set_time(d:Dictionary,l:float,p:float)->void:
	d[k_keywords[2]]=l
	d[k_keywords[3]]=p
	d[k_keywords[4]]=p/l

func get_fading(d:Dictionary,m:AnimationNodeStateMachinePlayback)->bool:
	if m!=null:
		if is_fading(m):
			d.clear();
			d[k_keywords[0]]=&"Transition"
			set_time(d,m.get_fading_length(),m.get_fading_position())
			d[k_keywords[5]]=m.get_fading_from_node()
			d[k_keywords[6]]=m.get_current_node()
			d[k_keywords[7]]=m.get_travel_path()
			return true
	return false

func get_state(d:Dictionary,m:AnimationNodeStateMachinePlayback,n:bool)->bool:
	if m!=null:
		d.clear();
		if n:d[k_keywords[0]]=&"Next"
		else:d[k_keywords[0]]=&"Current"
		if is_fading(m) and !n:
			d[k_keywords[1]]=m.get_fading_from_node()
			set_time(d,m.get_fading_from_length(),m.get_fading_from_play_position())
		else:
			d[k_keywords[1]]=m.get_current_node()
			set_time(d,m.get_current_length(),m.get_current_play_position())
		return true
	return false

func in_transition(l:int=0)->bool:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		return is_fading(m)
	return false

func get_transition(l:int=0)->Dictionary:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if get_fading(info,m):return info
	return LangExtension.k_empty_dictionary

func get_current(l:int=0)->Dictionary:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if get_state(info,m,false):return info
	return LangExtension.k_empty_dictionary

func get_next(l:int=0)->Dictionary:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if is_fading(m) and get_state(info,m,true):return info
	return LangExtension.k_empty_dictionary

func try_travel(m:AnimationNodeStateMachinePlayback,k:StringName,b:bool)->void:
	if m!=null:
		if features==0:m.travel(k,b);return
		#
		var n:int=0x1
		if is_fading(m):
			if get_fading(info,m):
				if info.current==k:n=0x3
				elif info.next==k:n=0x4
		else:
			if get_state(info,m,false):
				if info.name==k:n=0x4
		#
		if (n&0x2)!=0:m.next()
		if (n&0x4)!=0:m.start(k,b)
		elif (n&0x1)!=0:m.travel(k,b)

# Properties

func read(k:StringName)->Variant:
	if tree!=null:return tree.get(k)
	else:return super.get(k)

func write(k:StringName,v:Variant)->void:
	if tree!=null:tree.set(k,v)
	else:super.set(k,v)

func fetch(i:int,v:Variant=null)->Variant:
	if i>=0 and i<parameters.size():return read(parameters[i])
	else:return v

func apply(i:int,v:Variant)->void:
	if i>=0 and i<parameters.size():write(parameters[i],v)

# Methods

func setup(n:Node)->void:
	if player==null:player=get_node_or_null(^"../AnimationPlayer")
	if tree==null:tree=get_node_or_null(^"../AnimationTree")
	#
	if tree!=null:
		GodotExtension.set_anim_player(tree,player)
		GodotExtension.set_expression_node(tree,n)
		machines.clear()
		for it in layers:machines.append(tree.get(it))

func play(k:StringName,l:int=-1,f:float=0.25)->void:
	#if in_transition(l):print(get_current(l));print(get_next(l));print(get_transition(l))
	#
	var b:bool=true
	if f<=0.0:
		if l>=0:
			var it=get_machine(l)
			if it!=null:it.start(k,b)
		else:
			for it in machines:
				if it!=null:it.start(k,b)
	else:
		if l>=0:
			try_travel(get_machine(l),k,b)
		else:
			for it in machines:try_travel(it,k,b)

func dispatch(e:StringName)->void:
	if machine!=null:machine._on_event(self,e)
	else:print("{0}.{1} is missed.".format([name,e]))
