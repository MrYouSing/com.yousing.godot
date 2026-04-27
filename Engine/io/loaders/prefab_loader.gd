## The prefab version of [ResourcePreloader].
class_name PrefabLoader extends Runnable

@export_group("Preload")
@export var prefabs:Array[Resource]
@export var counts:PackedInt32Array

func run()->void:
	var s:Stage=Stage.instance
	var i:int;var j:int=counts.size()
	var n:Node;var c:int=0
	for it in prefabs:
		if it!=null:
			n=s.unpack(it);if i<j:c=counts[i]
			i=c;while i>0:i-=1;s.despawn(s.spawn(n,null,null,false))
