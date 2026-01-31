## A loader singleton for [AudioStream].
class_name AudioLoader

static var s_is_inited:bool
static var s_pools:Dictionary[StringName,Pool]

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	add_type(AudioStreamWAV,&".wav")
	add_type(AudioStreamMP3,&".mp3")
	add_type(AudioStreamOggVorbis,&".ogg")

static func add_type(c:Object,...a:Array)->void:
	if !s_is_inited:init()
	#
	var p:Pool=Pool.new(a[0],c)
	for it in a:s_pools[it]=p

static func load_from_file(f:String,c:bool=true)->AudioStream:
	if !FileAccess.file_exists(f):return
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f)
	if !s_is_inited:init()
	#
	var e:StringName=IOExtension.file_extension(f)
	var p:Pool=s_pools.get(e,null)
	if p!=null:
		var k:StringName=LangExtension.k_empty_name;if c:k=f
		return p.load(k,f)
	return null

class Pool:
	var name:StringName
	var clazz:Object
	var streams:Dictionary[StringName,AudioStream]
	
	func _init(n:StringName,c:Object)->void:
		name=n
		clazz=c

	func clear()->void:
		if streams.is_empty():return
		var it:AudioStream;for s in streams.values():
			it=s;if it!=null:it.free()
		streams.clear()

	func load(k:StringName,v:Variant)->AudioStream:
		var b:bool=!k.is_empty();var s:AudioStream=null
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
					return
			if b:streams[k]=s
		return s
