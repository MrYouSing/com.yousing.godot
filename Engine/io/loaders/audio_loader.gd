## A loader singleton for [AudioStream].
class_name AudioLoader

static var s_is_inited:bool
static var s_pools:Dictionary[String,Pool]

static func clear()->void:
	for it in s_pools:s_pools[it].clear()

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	Asset.on_clear.connect(clear)
	add_type(AudioStreamWAV,".wav")
	add_type(AudioStreamMP3,".mp3")
	add_type(AudioStreamOggVorbis,".ogg")

static func support(e:String)->bool:
	if not s_is_inited:init()
	#
	return s_pools.get(e,null)!=null

static func add_type(c:Object,...a:Array)->void:
	if not s_is_inited:init()
	#
	var p:Pool=Pool.new(a[0],c)
	s_pools[p.name]=p
	for it in a:s_pools[it]=p

static func load_from_file(f:String,c:bool=true)->AudioStream:
	if not FileAccess.file_exists(f):return null
	if not s_is_inited:init()
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f)
	#
	var e:String=IOExtension.file_extension(f)
	var p:Pool=s_pools.get(e,null)
	if p!=null:
		var k:String=LangExtension.k_empty_name;if c:k=f
		return p.load(k,f)
	return null

class Pool:
	var name:StringName
	var clazz:Object
	var streams:Dictionary[String,AudioStream]
	
	func _init(n:String,c:Object)->void:
		name=n.substr(1).to_upper()
		clazz=c

	func clear()->void:
		if streams.is_empty():return
		#var it:AudioStream;for s in streams.values():
		#	it=s;if it!=null:while(it.unreference()):pass
		streams.clear()

	func load(k:String,v:Variant)->AudioStream:
		var b:bool=not k.is_empty();var s:AudioStream=null
		if b:s=streams.get(k,null)
		if s==null:
			match typeof(v):
				TYPE_STRING,TYPE_STRING_NAME:
					var f:String=v
					s=clazz.load_from_file(f)
					s.resource_name=IOExtension.file_name(f)
				TYPE_PACKED_BYTE_ARRAY:
					s=clazz.load_from_buffer(v)
					s.resource_name=k
				_:
					return s
			if b:streams[k]=s
		return s
