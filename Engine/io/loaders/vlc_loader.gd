## A loader singleton for [url=https://github.com/xiSage/godot-vlc.git]VLC[/url] media.
class_name VlcLoader

static var s_is_inited:bool
static var s_extensions:PackedStringArray
static var s_streams:Dictionary[String,Resource]

static func clear()->void:
	s_streams.clear()

static func create_from_file(f:String)->Resource:
	if ClassDB.class_exists(&"VLCMedia"):
		var r:Resource=ClassDB.class_call_static(&"VLCMedia",&"load_from_file",f)
		r.resource_name=IOExtension.file_name(f);return r
	return null

static func create_from_url(f:String)->Resource:
	if ClassDB.class_exists(&"VLCMedia"):
		var r:Resource=ClassDB.class_call_static(&"VLCMedia",&"load_from_mrl",f)
		r.resource_name=IOExtension.file_name(f);return r
	return null

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	if not ClassDB.class_exists(&"VLCMedia"):return
	Asset.on_clear.connect(clear)
	#AudioLoader.init();VideoLoader.init()
	var s:GDScript=load("res://addons/godot-vlc/format_loader.gd")
	var l:Object=s.new();var e:String
	for it in l.extensions:
		e="."+it;if not AudioLoader.s_pools.has(e) and not VideoLoader.s_pools.has(e):
			s_extensions.append(e)

static func support(e:String)->bool:
	if not s_is_inited:init()
	return s_extensions.has(e)

static func load_from_file(f:String,c:bool=true)->Resource:
	if not FileAccess.file_exists(f):return create_from_url(f)
	if not s_is_inited:init()
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f,"VLCMedia")
	#
	var r:Resource=null;if c:
		r=s_streams.get(f,null)
		if r==null:r=create_from_file(f);s_streams[f]=r
	else:
		r=create_from_file(f)
	return r
