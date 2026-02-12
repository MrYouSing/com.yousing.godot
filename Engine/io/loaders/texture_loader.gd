## A loader singleton for [Texture].
class_name TextureLoader

static var s_is_inited:bool
static var s_textures:Dictionary[String,Texture]
static var s_extensions:PackedStringArray=[
".bmp",
".dds",
".exr",
".jpg",
".jpeg",
".ktx",
".png",
".svg",
".tga",
".webp",
]

static func support(e:String)->bool:
	return s_extensions.has(e)

static func clear()->void:
	s_textures.clear()

static func create_from_file(f:String)->Texture:
	#return IOExtension.import_asset(f,"ImageTexture")
	var t:Texture=ImageTexture.create_from_image(Image.load_from_file(f))
	t.resource_name=IOExtension.file_name(f);return t

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	Asset.on_clear.connect(clear)

static func load_from_file(f:String,c:bool=true)->Texture:
	if not FileAccess.file_exists(f):return null
	if not s_is_inited:init()
	if IOExtension.is_sandbox(f):return ResourceLoader.load(f,"ImageTexture")
	#
	var t:Texture=null;if c:
		var k:String=IOExtension.check_path(f).to_lower()
		t=s_textures.get(k,null)
		if t==null:t=create_from_file(f);s_textures[k]=t
	else:
		t=create_from_file(f)
	return t
