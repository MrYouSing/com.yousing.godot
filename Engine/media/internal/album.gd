## A collection which contains media assets.
class_name Album extends Resource

@export_group("Album")
@export var names:Array[StringName]
@export var clips:Array[Resource]
@export var paths:Array[StringName]
@export var weights:Array[float]

var is_inited:bool
var sum:float

func init()->void:
	if is_inited:return
	is_inited=true
	#
	if !paths.is_empty():
		clips.clear()
		for it in paths:
			if !it.is_empty():clips.append(load(it))
	#
	sum=0.0;for it in weights:sum+=it
	

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
	else:i=MathExtension.random_level(sum,weights)
	#
	if i>=0:return clips[i]
	else:return null
