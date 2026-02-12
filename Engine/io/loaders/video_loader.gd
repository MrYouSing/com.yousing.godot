## A loader singleton for [VideoStream].
class_name VideoLoader

static var s_is_inited:bool
static var s_pools:Dictionary[String,Pool]

static func clear()->void:
	for it in s_pools:s_pools[it].clear()

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	Asset.on_clear.connect(clear)
	add_type(&"VideoStreamTheora",".ogv")
	var k:StringName;var d:bool=true
	# TODO: Add supports from plugin.
	k=&"FFmpegVideoStream";if ClassDB.class_exists(k):
		# https://docs.unity3d.com/Manual/VideoSources-FileCompatibility.html
		match Application.get_platform():
			"Windows":add_type(k,".*",".asf",".avi",".dv",".m4v",".mov",".mp4",".mpg",".mpeg",".ogv",".vp8",".webm",".wmv",".flv")
			"macOS":add_type(k,".*",".dv",".m4v",".mov",".mp4",".mpg",".mpeg",".ogv",".vp8",".webm")
			"Linux":add_type(k,".*",".ogv",".vp8",".webm")
			_:add_type(k,".*",".mp4",".webm")
		if d:print(k+" is used.")
		return

static func support(e:String)->bool:
	if not s_is_inited:init()
	#
	var p:Pool=get_pool(e)
	if p!=null and p.extensions.has(e):return true
	return false

static func add_type(c:Variant,...a:Array)->void:
	if not s_is_inited:init()
	#
	var p:Pool=Pool.new(c,a)
	s_pools[c]=p
	for it in a:if not s_pools.has(it):s_pools[it]=p

static func get_pool(e:String)->Pool:
	if not s_is_inited:init()
	#
	var p:Pool=s_pools.get(e,null)
	if p==null:p=s_pools.get(".*",null)
	return p

static func load_from_file(f:String,s:VideoStream=null)->VideoStream:
	if not FileAccess.file_exists(f):return null
	if not s_is_inited:init()
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f)
	#
	var e:String=IOExtension.file_extension(f)
	var p:Pool=get_pool(e)
	if p!=null:
		if s==null:
			s=p.obtain(e)
		else:
			e=IOExtension.file_extension(s.file);
			if not p.extensions.has(e):
				var q:Pool=get_pool(e)
				if q!=null:q.recycle(s)
				s=p.obtain(e)
		p.load(s,f)
	return s

class Pool:
	var name:StringName
	var extensions:PackedStringArray
	var streams:Array[VideoStream]
	
	func _init(n:StringName,e:Array)->void:
		name=n
		extensions=e#Array(e,TYPE_STRING_NAME,LangExtension.k_empty_name,null)

	func clear()->void:
		if streams.is_empty():return
		#for it in streams:
		#	if it!=null:while(it.unreference()):pass
		streams.clear()

	func load(s:VideoStream,f:String)->void:
		s.file=f;s.resource_name=IOExtension.file_name(f)

	func obtain(e:String)->VideoStream:
		if extensions.has(".*"):
			if not extensions.has(e):extensions.append(e)
		#
		if streams.is_empty():return ClassDB.instantiate(name)
		else:return streams.pop_front()

	func recycle(s:VideoStream)->void:
		if s==null or streams.has(s):return
		streams.push_back(s)
