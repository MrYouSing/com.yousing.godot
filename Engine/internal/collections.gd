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
	var type:int
	var source:Object
	var creator:Callable
	var pool:Array[Object]

	func _init(s:Variant=null)->void:
		if s==null:return
		match typeof(s):
			TYPE_OBJECT:
				type=1;source=s
				if source is Script:type=0
			TYPE_CALLABLE:
				type=2;creator=s
			TYPE_ARRAY:
				type=2;creator=s[0];source=s[1]

	func create_from_class()->Object:
		if source is Script:
			return source.new()
		return null

	func create_from_obj()->Object:
		if source is Node:
			var tmp:Node=source.duplicate()
			tmp.name=source.name
			return tmp
		if source is Resource:
			var tmp:Resource=source.duplicate()
			tmp.resource_name=source.resource_name
			return tmp
		return null

	func create_from_func()->Object:
		match creator.get_argument_count():
			0:return creator.call()
			1:return creator.call(source)
			2:return creator.call(self,source)
			_:return null

	func create()->Object:
		match type:
			0:return create_from_class()
			1:return create_from_obj()
			2:return create_from_func()
		return null

	func obtain()->Object:
		if pool.is_empty():return create()
		else:return pool.pop_back()

	func recycle(o:Object)->void:
		if o==null:return
		if pool.has(o):printerr("Recycle {0} again!"%o);return
		pool.push_back(o)

class Ring:
	var array:Array
	var capacity:int
	var index:int
	
	func _init(c:int)->void:
		index=-1;capacity=c;array.resize(capacity)

	func peek()->Variant:
		return array[index%capacity]

	func place(v:Variant)->void:
		array[index%capacity]=v

	func pop()->Variant:
		index+=1
		return array[index%capacity]

	func push(v:Variant)->void:
		index+=1
		array[index%capacity]=v
