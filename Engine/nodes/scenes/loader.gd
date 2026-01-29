## A helper class for [ResourceLoader]
class_name Loader extends Node

const k_recycle:String="$(Recycle)"
static var s_pool:Collections.Pool=Collections.Pool.new(Loader)

static func obtain(k:StringName,p:Node,c:Callable)->Loader:
	var l:Loader=s_pool.obtain()
	l.name=k;GodotExtension.add_node(l,p,false)
	if !c.is_null():l.on_done.connect(c,CONNECT_ONE_SHOT)
	return l

static var s_is_inited:bool
static var s_file_api:Dictionary[StringName,Callable]

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	#
	s_file_api=Application.get_plugin(&"FilePlugin",true)
	if s_file_api.is_empty():
		s_file_api.exists=FileAccess.file_exists
		s_file_api.open=FileAccess.open
		s_file_api.text=LangExtension.k_empty_callable
		s_file_api.table=LangExtension.k_empty_callable
		s_file_api.asset=ResourceLoader.load

static func load_text(f:String)->String:
	if !s_is_inited:init()
	var m:Callable=s_file_api.text
	if !m.is_null():
		var s:String=m.call(f)
		if !s.is_empty():return s
	if s_file_api.exists.call(f):
		var a:FileAccess=s_file_api.open.call(f,FileAccess.READ)
		if a!=null:return a.get_as_text()
	return LangExtension.k_empty_string

static func load_table(f:String,d:String=",")->Array[PackedStringArray]:
	if !s_is_inited:init()
	var m:Callable=s_file_api.table
	if !m.is_null():
		var t:Array[PackedStringArray]=m.call(f)
		if !t.is_empty():return t
	if s_file_api.exists.call(f):
		var a:FileAccess=s_file_api.open.call(f,FileAccess.READ)
		if a!=null:
			var it=a.get_csv_line(d);var n:int=it.size()
			var t:Array[PackedStringArray];t.append(it)
			while !a.eof_reached():
				it=a.get_csv_line(d)
				if it.size()>=n:t.append(it)
			return t
	return LangExtension.k_empty_table

static func load_asset(f:String)->Resource:
	if !s_is_inited:init()
	var m:Callable=s_file_api.asset
	if !m.is_null():
		var t:Resource=m.call(f)
		if t!=null:return t
	if s_file_api.exists.call(f):
		return s_file_api.asset.call(f)
	return null

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
	if path.is_empty():set_process(false)
	elif state==-1:load("res://"+path)

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
