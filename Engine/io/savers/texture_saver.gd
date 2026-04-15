## A saver singleton for [Texture].
class_name TextureSaver

static var s_is_inited:bool
static var s_savers:Dictionary[String,Saver]
const s_extensions:PackedStringArray=[# Const for editor mode.
".dds",
".exr",
".jpg",
".png",
".webp",
]

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	#
	var s:Saver;for it in s_extensions:
		if not s_savers.has(it):
			s=Saver.new()
			s.file="save_"+it.substr(1,it.length()-1)
			s.buffer=s.file+"_to_buffer"
			s_savers[it]=s
	s_savers.set(".jpeg",s_savers.get(".jpg",null))

static func save_to_file(t:Texture,f:String)->void:
	if t==null:return
	if not s_is_inited:init()
	#
	var s:Saver=s_savers.get(IOExtension.file_extension(f),null)
	if s!=null:s.to_file(t,f)

class Saver:
	var file:StringName
	var buffer:StringName

	func to_file(t:Texture,f:String)->void:
		if t!=null:t.get_image().call(file,f)

	func to_buffer(t:Texture)->PackedByteArray:
		if t!=null:return t.get_image().call(buffer)
		else:return LangExtension.k_empty_bytes
