## A helper class for [ResourceLoader]
class_name Loader extends Node

const k_recycle:String="$(Recycle)"
static var s_pool:Collections.Pool=Collections.Pool.new()

static func obtain(k:StringName,p:Node,c:Callable)->Loader:
	var l:Loader=s_pool.obtain()
	if l==null:l=Loader.new()
	#
	l.name=k;GodotExtension.add_node(l,p,false)
	if !c.is_null():l.on_done.connect(c,CONNECT_ONE_SHOT)
	return l

@export_group("Loader")
@export var root:Node
@export var path:String
@export var type:String=""
@export var thread:bool=false
@export var cache:ResourceLoader.CacheMode=1

signal on_tick(l:Loader)
signal on_done(l:Loader)

var _progress:Array[float]

var state:ResourceLoader.ThreadLoadStatus=-1
var progress:float:
	get:
		match state:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:return _progress[0]
			ResourceLoader.THREAD_LOAD_LOADED:return 1.0
			_:return -1.0
var asset:Object
# Optional
var callback:Callable
var arguments:Array

func load(p:String)->void:
	path=p
	#
	var e:Error=ResourceLoader.load_threaded_request(p,type,thread,cache)
	if e==Error.OK:
		set_process(true)
		state=ResourceLoader.THREAD_LOAD_IN_PROGRESS
	else:
		printerr(error_string(e))
		state=ResourceLoader.THREAD_LOAD_FAILED
		_on_done()

func recycle()->void:
	# Cleanup.
	set_process(false);state=-1
	path=LangExtension.k_empty_string;asset=null
	# Teardown.
	callback=LangExtension.k_empty_callable
	arguments.clear()
	LangExtension.clear_signal(on_tick)
	LangExtension.clear_signal(on_done)
	GodotExtension.add_node(self,GodotExtension.s_hide,false)
	#
	name="Loader_%04d"%s_pool.pool.size()
	s_pool.recycle(self);

func _ready()->void:
	if state==-1 and !path.is_empty():load("res://"+path)
	else:set_process(false)

func _process(delta:float)->void:
	if state==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		state=ResourceLoader.load_threaded_get_status(path,_progress)
		match state:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:_on_tick()
			_:_on_done()

func _on_tick()->void:
	on_tick.emit(self)

func _on_done()->void:
	if state==ResourceLoader.THREAD_LOAD_LOADED:
		asset=ResourceLoader.load_threaded_get(path)
	on_done.emit(self)
	if path==k_recycle:recycle();return
	# Cleanup.
	set_process(false);state=-1
	path=LangExtension.k_empty_string;asset=null
