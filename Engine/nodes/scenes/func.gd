## A helper class for persistent functions.
class_name Func extends Node

static func create(n:Node,p:NodePath,c:Callable,a:Array)->Func:
	if n!=null:
		var f:Func=n.get_node_or_null(p)
		if f==null:
			f=Func.new();f.name=StringName(p)
			GodotExtension.add_node(f,n,false)
		#
		f.callable=c
		if not a.is_empty():f.arguments.assign(a)
		return f
	return null

static func update(n:Node,p:NodePath,c:Callable,a:Array,i:int=0)->Func:
	var f:Func=create(n,p,c,a)
	if f!=null:
		if f.arguments.size()<a.size()+2:
			f.arguments.append(f)
			f.arguments.append(0.0)
		f.process(i)
	return f

@export_group("Func")
@export var target:Node
@export var path:NodePath
@export var method:StringName
@export var arguments:Array

var inited:bool
var callable:Callable=LangExtension.k_empty_callable:
	set(x):
		if x.is_valid():
			inited=true
			callable=x
		else:
			inited=false
			callable=LangExtension.k_empty_callable

func process(i:int)->void:
	match i:
		-1:process_mode=PROCESS_MODE_DISABLED
		0:process_mode=PROCESS_MODE_INHERIT;set_process(true);set_physics_process(false)
		1:process_mode=PROCESS_MODE_ALWAYS;set_process(true);set_physics_process(false)
		2:process_mode=PROCESS_MODE_INHERIT;set_process(false);set_physics_process(true)
		3:process_mode=PROCESS_MODE_ALWAYS;set_process(false);set_physics_process(true)

func init()->void:
	if inited:return
	inited=true
	#
	if not path.is_empty():
		var p:Node=target;if p==null:p=GodotExtension.s_root
		var n:Node=p.get_node_or_null(path)
		if n!=null:target=n
	if target!=null and target.has_method(method):
		callable=Callable(target,method)
	else:
		callable=LangExtension.k_empty_callable

func invoke()->Variant:
	if not inited:init()
	#
	if callable.is_valid():
		return callable.callv(arguments)
	else:
		return null

func invoke_with(...a:Array)->Variant:
	if not inited:init()
	#
	if callable.is_valid():
		if a.is_empty():return callable.callv(arguments)
		else:return callable.callv(a)
	else:
		return null

func invoke_pass(...a:Array)->Variant:
	if not inited:init()
	#
	if callable.is_valid():
		return callable.callv(arguments)
	else:
		return null

func _enter_tree()->void:
	if is_node_ready():return
	process(-1)

func _process(d:float)->void:
	if process_mode==PROCESS_MODE_ALWAYS:d=1.0/Application.get_fps()
	arguments[-1]+=d;invoke()

func _physics_process(d:float)->void:
	if process_mode==PROCESS_MODE_ALWAYS:d=1.0/Engine.physics_ticks_per_second
	arguments[-1]+=d;invoke()
