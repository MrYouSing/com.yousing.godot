class_name LangExtension

const k_empty_string:String=""
const k_empty_array:Array=[]
const k_empty_signal:Signal=Signal()

static var s_none_string:String="None"
static var s_benchmark_names:Array[String]
static var s_benchmark_times:Array[float]

# https://learn.microsoft.com/zh-cn/dotnet/api/system.notimplementedexception
static var e_not_implemented:Dictionary={
	"text":"Not Implemented Exception"
}

static func throw_exception(c:Object,e:Dictionary)->void:
	push_error(e["text"])

static func get_time()->float:
	return Time.get_ticks_msec()*0.001

static func begin_benchmark(c:String)->void:
	s_benchmark_names.push_back(c)
	s_benchmark_times.push_back(get_time())

static func end_benchmark()->void:
	var c:String=s_benchmark_names.pop_back()
	var t:float=s_benchmark_times.pop_back()
	var d:float=get_time()
	print(c.format([t,d-t,d]))
	
static func clear_signal(s:Signal)->void:
	if !s.is_null() and s.has_connections():
		for it in s.get_connections():
			it.disconnet(it.callable)

static func bake_signal(c:Object,k:StringName,t:Array,m:Array[StringName])->Signal:
	if !c.has_user_signal(k):c.add_user_signal(k)
	var tmp:Signal=Signal(c,k);var j:int=m.size()
	var i:int=-1;for it in t:
		i+=1;if i<j:k=m[i]
		if it!=null and it.has_method(k):
			var d=Callable(it,k)
			if !tmp.is_connected(d):tmp.connect(d)
	return tmp

static func merge_signal(c:Object,s:Signal,r:Signal,a:Array,m:StringName,f:int=0)->Signal:
	if s.is_null():
		if !c.has_user_signal(m):c.add_user_signal(m)
		s=Signal(c,m)
	else:
		clear_signal(s)
	#
	if !r.is_null() and r.has_connections():# From Engine
		for it in r.get_connections():
			s.connect(it.callable,it.flags)
	if !a.is_empty() and !m.is_empty():# From User
		for it in a:
			if it!=null and it.has_method(m):
				var d:Callable=Callable(it,m)
				if !s.is_connected(d):s.connect(d,f)
	return s
