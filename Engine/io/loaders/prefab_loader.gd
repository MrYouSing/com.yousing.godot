## The prefab version of [ResourcePreloader].
class_name PrefabLoader extends Runnable

@export_group("Preload")
@export var prefabs:Array[Resource]
@export var counts:PackedInt32Array

func run()->void:
	var s:Stage=Stage.instance
	var j:int=counts.size();var k:int
	var n:Node;var c:int=0
	var i:int=-1;for it in prefabs:
		i+=1;if it==null:continue
		n=s.unpack(it);if i<j:c=counts[i]
		k=c;while k>0:k-=1;s.despawn(s.spawn(n,null,null,false))
