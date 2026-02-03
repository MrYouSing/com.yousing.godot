## A loader singleton for [VideoStream].
class_name VideoLoader

static var s_is_inited:bool
static var s_pools:Dictionary[StringName,Pool]

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	add_type(&"VideoStreamTheora",&".ogv")
	add_type(&"FFmpegVideoStream",&".*")

static func add_type(c:Variant,...a:Array)->void:
	if !s_is_inited:init()
	#
	var p:Pool=Pool.new(c,a)
	for it in a:s_pools[it]=p

static func get_pool(e:StringName)->Pool:
	if !s_is_inited:init()
	#
	var p:Pool=s_pools.get(e,null)
	if p==null:p=s_pools.get(&".*",null)
	return p

static func load_from_file(f:String,s:VideoStream=null)->VideoStream:
	if !FileAccess.file_exists(f):return
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f)
	if !s_is_inited:init()
	#
	var e:StringName=IOExtension.file_extension(f)
	var p:Pool=get_pool(e)
	if p!=null:
		if s==null:
			s=p.obtain(e)
		else:
			e=IOExtension.file_extension(s.file);
			if !p.extensions.has(e):
				var q:Pool=get_pool(e)
				if q!=null:q.recycle(s)
				s=p.obtain(e)
		s.file=f
	return s

class Pool:
	var name:StringName
	var extensions:Array[StringName]
	var streams:Array[VideoStream]
	
	func _init(n:StringName,e:Array)->void:
		name=n
		extensions=Array(e,TYPE_STRING_NAME,LangExtension.k_empty_name,null)

	func clear()->void:
		if streams.is_empty():return
		#for it in streams:
		#	if it!=null:while(it.unreference()):pass
		streams.clear()

	func obtain(e:StringName)->VideoStream:
		if extensions.has(".*"):
			if !extensions.has(e):extensions.append(e)
		#
		if streams.is_empty():return ClassDB.instantiate(name)
		else:return streams.pop_front()

	func recycle(s:VideoStream)->void:
		if s==null or streams.has(s):return
		streams.push_back(s)
