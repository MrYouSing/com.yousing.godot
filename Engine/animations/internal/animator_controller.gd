## A shared resource for animation system.
class_name AnimatorController extends Resource

@export_group("Animation")
@export var asset:AnimationRootNode
@export var layers:Array[AnimatorLayer]
@export var parameters:Array[StringName]
@export var sync_parameters:Dictionary[StringName,Array]

static func call_parse(k:StringName,l:int,t:Callable,f:Callable)->Variant:
	if k.ends_with("_exit_time"):if t!=null:return t.call(k.substr(0,k.length()-10),l)
	elif k.ends_with("_exit_func"):if f!=null:return f.call(k.substr(0,k.length()-10),l)
	return null

func parse(c:Animator,k:StringName,l:int)->Variant:
	if k.ends_with("_exit_time"):return exit_time(c,k.substr(0,k.length()-10),l)
	elif k.ends_with("_exit_func"):return exit_func(c,k.substr(0,k.length()-10),l)
	return null

func setup(c:Animator)->void:
	if c==null:return
	if c.tree!=null and c.tree.tree_root==null and asset!=null:
		c.tree.tree_root=asset
	#
	var n:Node=GodotExtension.get_expression_node(c.tree)
	if n!=null and c!=n:
		if (c.features&0x01)!=0:return
		var f:Callable;
		f=func(k:StringName,l:int)->bool:return exit_time(c,k,l)
		n.set(&"exit_time",f)
		f=func(k:StringName,l:int)->bool:return exit_func(c,k,l)
		n.set(&"exit_func",f)

func teardown(c:Animator)->void:
	if c==null:return
	if c.tree!=null and c.tree.tree_root==asset:
		c.tree.tree_root=null
	#
	var n:Node=GodotExtension.get_expression_node(c.tree)
	if n!=null and c!=n:
		if (c.features&0x01)!=0:return
		n.set(&"exit_time",null)
		n.set(&"exit_func",null)

func get_layer(l:int)->AnimatorLayer:
	var a:AnimatorLayer
	if l>=0 and l<layers.size():
		a=layers[l];if a!=null:a.index=l
	return a

func sync_write(c:Animator,k:StringName,v:Variant)->bool:
	if c!=null and sync_parameters.has(k):
		var tmp:AnimatorController=c.controller;c.controller=null
		for it in sync_parameters[k]:c.write(it,v)
		c.controller=tmp
		return true
	return false

func exit_info(c:Animator,o:Dictionary[StringName,Variant],k:StringName,d:Dictionary[StringName,Variant],l:int=0)->bool:
	if c==null:return false
	#
	if o.has(k):
		var v:Variant=o.get(k);
		if typeof(v)==TYPE_ARRAY:# Fix value.
			l=v[0];v=v[1]
		if l>=0:# Check machine.
			var m:Object=c.get_machine(l)
			if m!=null:
				if c.is_fading(m) or !c.get_state(m,d,false):return false
		d.argument=v;return true
	return false

func exit_time(c:Animator,k:StringName,l:int=0)->bool:
	if c==null:return false
	#
	var a:AnimatorLayer=layers[l]
	if a!=null and exit_info(c,a.exit_times,k,c.info,l):
		return c.info.time>=c.info.argument
	return false

func exit_func(c:Animator,k:StringName,l:int=0)->bool:
	if c==null:return false
	#
	var a:AnimatorLayer=layers[l]
	if a!=null and exit_info(c,a.exit_funcs,k,c.info,l):
		return c.context.call(c.info.argument,c.info)
	return false

func exit_eval(c:Animator,l:int=0)->bool:
	if c==null:return false
	#
	var a:AnimatorLayer=layers[l]
	if a!=null:
		var m:Object=c.get_machine(l)
		if m is AnimationNodeStateMachinePlayback:
			if !c.is_fading(m) and c.get_state(m,c.info,false):
				var k:StringName=c.info.name;var t:float=c.info.time
				if exit_info(c,a.exit_times,k,c.info,-1) and t>=c.info.argument:return true
				if exit_info(c,a.exit_funcs,k,c.info,-1) and c.context.call(c.info.argument):return true
				return false
	return false

func exit_sync(c:Animator,m:int,b:bool)->void:
	if c==null:return
	#
	var a:AnimatorLayer;for i in c.machines.size():
		if m&(1<<i)==0:continue
		a=layers[i];if a==null:continue
		#
		c.write(a.exit,b)

func exit_tick(c:Animator,m:int)->void:
	if c==null:return
	#
	var a:AnimatorLayer;for i in c.machines.size():
		if m&(1<<i)==0:continue
		#
		if exit_eval(c,i):c.write(layers[i].exit,true)
