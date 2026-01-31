## A placeholder model for ui pattern.
class_name PlaceholderModel extends Resource

@export_group("Model")
@export var node:NodePath
@export var resource:Resource
@export_group("Observer")
@export var rate:float=-1.0
@export var keys:Array[StringName]

var _is_inited:bool
var _model:Object
var _stub:ViewModel.Stub
var _call:int=Juggler.k_invalid_id

func _bind(s:ViewModel.Stub)->void:
	if _stub!=null:
		if _call!=Juggler.k_invalid_id:
			Juggler.instance.kill_call(_call)
			_call=Juggler.k_invalid_id
	_stub=s
	if _stub!=null:
		if rate>=0.0:
			_call=Juggler.instance.repeat_call(_tick,LangExtension.k_empty_array,rate,rate)

func _tick()->void:
	if _stub!=null:
		if keys.is_empty():_stub.refresh()
		else:for it in keys:_stub.verify(it)

func init()->void:
	if _is_inited:return
	_is_inited=true
	#
	if _model!=null:
		pass
	elif !node.is_empty():
		_model=GodotExtension.s_root.get_node_or_null(node)
	else:
		_model=resource

func _get(k:StringName)->Variant:
	if !_is_inited:init()
	if _model!=null:return _model.get(k)
	else:return null

func _set(k:StringName,v:Variant)->bool:
	if k.begins_with("metadata/"):return false
	if !_is_inited:init()
	if _model!=null:_model.set(k,v);return true
	else:return false
