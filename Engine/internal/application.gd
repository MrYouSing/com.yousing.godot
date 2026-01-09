## Provides access to application runtime data.
class_name Application

# Engine APIs

static var s_app_frames:int=-1
static var s_app_time:float=-1.0
static var s_app_fps:int=-1
static var s_app_delta:float=-1.0
static var s_app_resolution:Vector2=Vector2.ZERO
static var s_app_plugins:Dictionary[StringName,Dictionary]
static var s_bm_names:Array[String]
static var s_bm_times:Array[float]

static func get_frames()->int:
	if s_app_frames>=0:return s_app_frames
	return Engine.get_process_frames()

static func get_time()->float:
	if s_app_time>=0.0:return s_app_time
	return Time.get_ticks_msec()*0.001

static func get_fps()->int:
	if s_app_fps>=0:return s_app_fps
	var n:int=Engine.max_fps
	if n<=0:
		n=Engine.physics_ticks_per_second
		if n<=0:n=60
	return n

static func get_delta()->float:
	if s_app_delta>=0.0:return s_app_delta
	return 1.0/get_fps()

static func get_resolution()->Vector2:
	if !s_app_resolution.is_zero_approx():return s_app_resolution
	var s:Vector2i=Engine.get_main_loop().root.size
	return Vector2(s.x,s.y)

static func get_plugin(k:StringName,a:bool)->Dictionary[StringName,Callable]:
	if s_app_plugins.has(k):
		return s_app_plugins[k]
	elif a:
		var v:Dictionary[StringName,Callable]={}
		s_app_plugins[k]=v;return v
	return LangExtension.k_empty_dictionary

static func set_plugin(k:StringName,v:Dictionary[StringName,Callable])->void:
	if s_app_plugins.has(k):
		s_app_plugins[k].assign(v)
	else:
		s_app_plugins[k]=v

static func begin_benchmark(c:String)->void:
	s_bm_names.push_back(c)
	s_bm_times.push_back(get_time())

static func end_benchmark()->void:
	var c:String=s_bm_names.pop_back()
	var t:float=s_bm_times.pop_back()
	var d:float=get_time()
	print(c.format([t,d-t,d]))
