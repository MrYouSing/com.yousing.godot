## Extension classes for [Array] and [Dictionary]
class_name Collections

static func benchmark_for(n:int,c:int=1000)->void:
	var a:Array[Pool];
	a.resize(c);a.fill(Pool.new())
	#
	Application.begin_benchmark("For it uses {0}->{2}:{1}s")
	for i in n:for it in a:it.obtain()
	Application.end_benchmark()
	Application.begin_benchmark("For [] uses {0}->{2}:{1}s")
	for i in n:for j in a.size():a[j].obtain()
	Application.end_benchmark()

class Pool:
	var source:Object
	var creator:Callable
	var pool:Array[Object]
	
	func create()->Object:
		if !creator.is_null():
			return creator.call(self,source)
		if source!=null:
			if source is Node:
				var tmp:Node=source.duplicate()
				tmp.name=source.name
				return tmp
			if source is Resource:
				var tmp:Resource=source.duplicate()
				tmp.resource_name=source.resource_name
				return tmp
		return null

	func obtain()->Object:
		if pool.is_empty():return create()
		else:return pool.pop_back()

	func recycle(o:Object)->void:
		if o==null:return
		if pool.has(o):printerr("Recycle {0} again!"%o);return
		pool.push_back(o)
