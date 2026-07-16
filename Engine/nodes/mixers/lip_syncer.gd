## A tool class for lip synchronization.
class_name LipSyncer extends Node

@export_group("Lip Sync")
@export var path:NodePath
@export var inputs:Array[Node]
@export var mixer:CompositeMixer
@export var outputs:Array
@export var weights:PackedVector4Array

var _temp:PackedFloat32Array

func sync(i:int,f:float)->void:
	var v:Variant=outputs[i]
	var w:Vector4=Vector4.ONE
	if i<weights.size():w=weights[i]
	match typeof(v):
		TYPE_OBJECT:
			pass
		TYPE_ARRAY:
			pass
		TYPE_STRING_NAME:
			if mixer!=null:
				_sync(mixer.index_of(v),f*w.x)
		TYPE_PACKED_STRING_ARRAY:
			if mixer!=null:
				var j:int=-1;for it in v:
					j+=1
					_sync(mixer.index_of(it),f*w[j])

func _sync(i:int,f:float)->void:
	if i>=0:_temp[i]+=f
	else:push_error("Invalid ID!!!!")

func _process(d:float)->void:
	if mixer!=null:
		var n:int=mixer.mixers.size()
		if _temp.size()<n:_temp.resize(n)
		else:_temp.fill(0.0)
		#
		var f:float
		var i:int=-1;for it in inputs:
			i+=1;if it==null:continue
			f=it.get_indexed(path)
			if f>0.0:sync(i,f)
		#
		for j in n:_temp[j]=clampf(_temp[j],0.0,1.0)
		mixer.flush(_temp)
