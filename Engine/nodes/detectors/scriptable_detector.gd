## A custom detector driven by scripts.
class_name ScriptableDetector extends BaseDetector

static var s_layers:Array[Layer]=Layer.array(32)

static func register_at(a:Node,l:int=0)->void:
	s_layers[l].register(a)

static func unregister_at(a:Node,l:int=0)->void:
	s_layers[l].unregister(a)

static func register_by(a:Node,m:int=1)->void:
	var i:int=-1;for it in s_layers:
		i+=1;if m&(1<<i)!=0:it.register(a)

static func unregister_by(a:Node,m:int=1)->void:
	var i:int=-1;for it in s_layers:
		i+=1;if m&(1<<i)!=0:it.unregister(a)

func detect()->bool:
	clear();var p:Vector3=GodotExtension.get_global_position(root)
	var i:int=-1;for it in s_layers:
		i+=1;if mask&(1<<i)!=0:for a in it.agents:
			if a!=null&&eval(a):
				apply(Physics.HitInfo.from_points(a,GodotExtension.get_global_position(a),p))
				_on_find(a)
	if targets.size()>0:
		target=targets[0]
		return true
	else:
		return false

func eval(a:Node)->bool:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)
	return false

class Layer:
	static func array(n:int)->Array[Layer]:
		var a:Array[Layer]=Array()
		a.resize(n);for i in n:a[i]=Layer.new()
		return a

	var agents:Array[Node]

	func register(a:Node)->void:
		if a==null:return
		var i:int=agents.find(a);if i>=0:return
		agents.append(a)

	func Unregister(a:Node)->void:
		if a==null:return
		var i:int=agents.find(a);if i<0:return
		agents.remove_at(i)
