## A collection which contains media assets.
class_name Album extends Resource

@export_group("Album")
@export var names:Array[StringName]
@export var clips:Array[Resource]
@export var paths:Array[StringName]
@export var rates:Array[float]

var is_inited:bool
var sum:float

static func from_path(p:String)->Album:
	var d:DirAccess=DirAccess.open(p)
	if d!=null:
		var a:Album=Album.new()
		a.resource_name=LangExtension.file_name(p)
		for it in d.get_files():
			if it.ends_with(".import"):continue
			a.clips.append(load(LangExtension.combine_path(p,it)))
		for it in d.get_directories():
			a.clips.append(from_path(LangExtension.combine_path(p,it)))
		return a
	return null

func init()->void:
	if is_inited:return
	is_inited=true
	#
	if !paths.is_empty():
		clips.clear()
		for it in paths:
			if !it.is_empty():clips.append(load(it))
	#
	sum=0.0;for it in rates:sum+=it
	

func load(k:StringName)->Resource:
	if !is_inited:init()
	#
	var tmp:Resource=null
	if !names.is_empty():
		var i:int=names.find(k)
		if i>=0:tmp=clips[i]
	else: 
		for it in clips:
			if it!=null and it.resource_name==k:tmp=it;break
	#
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
