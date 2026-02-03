## A placeholder model for ui pattern.
class_name PlaceholderModel extends AbsModel

@export_group("Model")
@export var node:NodePath
@export var resource:Resource
@export_group("Observer")
@export var rate:float
@export var keys:Array[StringName]

var _model:Object
var _call:int=Juggler.k_invalid_id

func _bind(s:ViewModel.Stub)->void:
	if _stub!=null:
		if _call!=Juggler.k_invalid_id:
			Juggler.instance.kill_call(_call)
			_call=Juggler.k_invalid_id
	_stub=s
	if _stub!=null:
		var f:float=MathExtension.time_delta(rate);
		if is_zero_approx(f):return
		_call=Juggler.instance.repeat_call(_tick,LangExtension.k_empty_array,f,f)

func _tick()->void:
	if _stub!=null:
		if keys.is_empty():_stub.refresh()
		else:for it in keys:_stub.verify(it)

func read(k:StringName,v:Variant=null)->Variant:
	if _model!=null:return _model.get(k)
	else:return v

func write(k:StringName,v:Variant)->void:
	if _model!=null:_model.set(k,v);

func init()->void:
	if _is_inited:return
	super.init()
	#
	if _model!=null:
		pass
	elif !node.is_empty():
		_model=GodotExtension.s_root.get_node_or_null(node)
	else:
		_model=resource
