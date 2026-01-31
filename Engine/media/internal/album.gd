## A collection which contains media assets.
class_name Album extends Resource

@export_group("Album")
@export var names:Array[StringName]
@export var clips:Array[Resource]
@export var paths:Array[StringName]
@export var rates:Array[float]

var is_inited:bool
var sum:float
var library:Dictionary[StringName,Resource]

static func from_path(p:String)->Album:
	var d:DirAccess=DirAccess.open(p)
	if d!=null:
		var a:Album=Album.new()
		a.resource_name=IOExtension.file_name(p)
		for it in d.get_files():
			if it.ends_with(".import"):continue
			a.names.append(IOExtension.file_name_only(it))
			a.clips.append(load(IOExtension.combine_path(p,it)))
		for it in d.get_directories():
			a.names.append(IOExtension.file_name_only(it))
			a.clips.append(from_path(IOExtension.combine_path(p,it)))
		return a
	return null

func init()->void:
	if is_inited:return
	is_inited=true
	#
	if !paths.is_empty():
		clips.clear();names.clear()
		var c:Resource;for it in paths:
			if !it.is_empty():
				c=load(it);if c==null:continue
				clips.append(c);names.append(IOExtension.file_name_only(it))
	if names.size()>0:
		library.clear();
		var i:int=-1;for it in clips:
			i+=1;library[names[i]]=it
	#
	sum=0.0;for it in rates:sum+=it
	

func load(k:StringName)->Resource:
	if !is_inited:init()
	#
	var tmp:Resource=library.get(k,null)
	if tmp!=null and tmp is Album:
		tmp=tmp.random()
	return tmp

func random()->Resource:
	if !is_inited:init()
	#
	var i:int=-1
	if sum<=0.0:i=randi()%clips.size()
	else:i=MathExtension.random_level(sum,rates)
	#
	if i>=0:return clips[i]
	else:return null
