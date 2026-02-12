## A tool class for hover management.
class_name UIHover extends Node

@export_group("Hover")
@export var timeout:float=1.0
@export var view:Node
@export var nodes:Array[Node]

var _enters:Array[Callable]
var _exits:Array[Callable]
var _hover:bool
var _node:Node
var _time:float=-1.0

func get_hover()->Node:
	return _node

func set_hover(n:Node)->void:
	if n!=null:
		if _time<0.0:# Down
			GodotExtension.set_enabled(view,true)
		if n!=_node:# Change
			if view!=null:view.set(&"model",n)
		_time=Application.get_time()
	else:
		if _time>=0.0:# Up
			GodotExtension.set_enabled(view,false)
		_time=-1.0
	_node=n

func add_hover(n:Node)->void:
	if n==null or nodes.has(n):return
	if is_node_ready():
		var c:Callable=_on_enter.bind(n)
		_enters.append(c);LangExtension.try_signal(n,&"mouse_entered",c)
		c=_on_exit.bind(n)
		_exits.append(c);LangExtension.try_signal(n,&"mouse_exited",c)
	nodes.append(n)

func remove_hover(n:Node)->void:
	if n==null:return
	var i:int=nodes.find(n);if i<0:return
	nodes[i]=null
	LangExtension.remove_signal(n,&"mouse_entered",_enters[i])
	LangExtension.remove_signal(n,&"mouse_exited",_exits[i])
	_enters[i]=LangExtension.k_empty_callable
	_exits[i]=LangExtension.k_empty_callable

func _on_enter(n:Node)->void:
	_hover=true;set_hover(n)

func _on_exit(n:Node)->void:
	if n==_node:_hover=false

func _ready()->void:
	var n:int=nodes.size();var j:int=_enters.size()
	if j<n:_enters.resize(n);_exits.resize(n)
	var it:Node;for i in n:
		it=nodes[i];if it==null:continue
		if i>=j:
			_enters[i]=_on_enter.bind(it)
			_exits[i]=_on_exit.bind(it)
		LangExtension.try_signal(it,&"mouse_entered",_enters[i])
		LangExtension.try_signal(it,&"mouse_exited",_exits[i])

func _exit_tree()->void:
	var n:int=nodes.size();
	var it:Node;for i in n:
		it=nodes[i];if it==null:continue
		LangExtension.remove_signal(it,&"mouse_entered",_enters[i])
		LangExtension.remove_signal(it,&"mouse_exited",_exits[i])
	#_enters.clear();_exits.clear()

func _process(d:float)->void:
	if not _hover and _time>=0.0:
		if Application.get_time()-_time>=timeout:
			set_hover(null)
