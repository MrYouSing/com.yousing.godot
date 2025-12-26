## A wrapper class for animation system.
class_name Animator extends Node

@export_group("Animation")
@export var player:AnimationPlayer
@export var tree:AnimationTree
@export_flags("Auto Exit","Smart Travel","Reserved 0","Reserved 1")
var features:int=-1
@export_group("State Machine")
@export var machine:BaseMachine
@export var controller:AnimatorController

var context:Object=self
var machines:Array[Object]
var info:Dictionary[StringName,Variant]={}

# State Machine

func has_layer(l:int)->bool:
	return l>=0 and l<machines.size()

func get_layer(l:int)->AnimatorLayer:
	if controller==null:return null
	return controller.get_layer(l)

func get_machine(l:int)->Object:
	if l>=0 and l<machines.size():return machines[l]
	else:return null

func set_time(d:Dictionary[StringName,Variant],l:float,p:float)->void:
	d.duration=l
	d.time=p
	d.progress=p/l

func is_fading(m:AnimationNodeStateMachinePlayback)->bool:
	if m!=null:
		return !m.get_fading_from_node().is_empty()
	return false

func get_fading(m:AnimationNodeStateMachinePlayback,d:Dictionary[StringName,Variant])->bool:
	if m!=null:
		if is_fading(m):
			d.clear();
			d.type=&"Transition"
			set_time(d,m.get_fading_length(),m.get_fading_position())
			d.current=m.get_fading_from_node()
			d.next=m.get_current_node()
			d.path=m.get_travel_path()
			return true
	return false

func get_state(m:AnimationNodeStateMachinePlayback,d:Dictionary[StringName,Variant],n:bool)->bool:
	if m!=null:
		d.clear();
		if n:d.type=&"Next"
		else:d.type=&"Current"
		if is_fading(m) and !n:
			d.name=m.get_fading_from_node()
			set_time(d,m.get_fading_from_length(),m.get_fading_from_play_position())
		else:
			d.name=m.get_current_node()
			set_time(d,m.get_current_length(),m.get_current_play_position())
		return true
	return false

func in_transition(l:int=0)->bool:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		return is_fading(m)
	return false

func get_transition(l:int=0)->Dictionary[StringName,Variant]:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if get_fading(m,info):return info
	return LangExtension.k_empty_dictionary

func get_current(l:int=0)->Dictionary[StringName,Variant]:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if get_state(m,info,false):return info
	return LangExtension.k_empty_dictionary

func get_next(l:int=0)->Dictionary[StringName,Variant]:
	var m:Object=get_machine(l)
	if m is AnimationNodeStateMachinePlayback:
		if is_fading(m) and get_state(m,info,true):return info
	return LangExtension.k_empty_dictionary

func try_travel(m:AnimationNodeStateMachinePlayback,k:StringName,b:bool)->void:
	if m!=null:
		if (features&0x02)==0:m.travel(k,b);return
		#
		var n:int=0x1
		if is_fading(m):
			if get_fading(m,info):
				if info.current==k:n=0x3
				elif info.next==k:n=0x4
				else:n=0x4
		else:
			if get_state(m,info,false):
				if info.name==k:n=0x4
		#
		if (n&0x2)!=0:m.next()
		if (n&0x4)!=0:m.start(k,b)
		elif (n&0x1)!=0:m.travel(k,b)

# Properties

func _get(k:StringName)->Variant:
	var v:Variant=null
	if controller!=null:v=controller.parse(self,k,0)
	return v

func read(k:StringName)->Variant:
	if tree!=null:return tree.get(k)
	else:return super.get(k)

func write(k:StringName,v:Variant)->void:
	if tree!=null:tree.set(k,v)
	else:super.set(k,v)

func index(i:int)->bool:
	return i>=0 and controller!=null and i<controller.parameters.size()

func fetch(i:int,v:Variant=null)->Variant:
	if index(i):return read(controller.parameters[i])
	else:return v

func apply(i:int,v:Variant)->void:
	if index(i):write(controller.parameters[i],v)

# Methods

func setup(n:Node)->void:
	if n==null:n=self
	if player==null:player=get_node_or_null(^"../AnimationPlayer")
	if tree==null:tree=get_node_or_null(^"../AnimationTree")
	#
	if tree!=null:
		GodotExtension.set_anim_player(tree,player)
		GodotExtension.set_expression_node(tree,n)
		if controller!=null:
			machines.clear()
			for it in controller.layers:
				if it!=null:machines.append(read(it.name))
	#
	if controller!=null:controller.setup(self)

func teardown()->void:
	if controller!=null:controller.teardown(self)
	#
	player=null;tree=null;machines.clear()

func play(k:StringName,l:int=-1,f:float=0.25)->void:
	if(features&0x01)!=0:stop(l)
	#
	var b:bool=true
	if f<=0.0:
		if has_layer(l):
			var m:Object=machines[l]
			if m!=null:m.start(k,b)
		else:
			var i:int=-1;for it in machines:
				i+=1;if l&(1<<i)==0:continue
				#
				if it!=null:it.start(k,b)
	else:
		if has_layer(l):
			try_travel(machines[l],k,b)
		else:
			var i:int=-1;for it in machines:
				i+=1;if l&(1<<i)==0:continue
				#
				try_travel(it,k,b)

func stop(l:int=-1)->void:
	if controller!=null:
		if has_layer(l):controller.exit_sync(self,1<<l,false)
		else:controller.exit_sync(self,l,false)

func dispatch(e:StringName)->void:
	if machine!=null:machine._on_event(self,e)
	else:print("{0}.{1} is missed.".format([name,e]))

func _process(delta:float)->void:
	if (features&0x01)!=0 and controller!=null:
		controller.exit_tick(self,-1)
