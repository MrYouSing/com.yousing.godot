## Provides access to application runtime data.
class_name Application

# Engine APIs

static var s_app_frames:int=-1
static var s_app_time:float=-1.0
static var s_app_fps:int=-1
static var s_app_delta:float=-1.0
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

static func begin_benchmark(c:String)->void:
	s_bm_names.push_back(c)
	s_bm_times.push_back(get_time())

static func end_benchmark()->void:
	var c:String=s_bm_names.pop_back()
	var t:float=s_bm_times.pop_back()
	var d:float=get_time()
	print(c.format([t,d-t,d]))
