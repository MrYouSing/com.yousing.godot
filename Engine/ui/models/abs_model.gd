## The abstract model for ui pattern.
@abstract class_name AbsModel extends Resource

var _is_inited:bool
var _stub:ViewModel.Stub

@abstract func read(k:StringName,v:Variant=null)->Variant
@abstract func write(k:StringName,v:Variant)->void

func _bind(s:ViewModel.Stub)->void:
	if _stub!=null:pass
	_stub=s
	if _stub!=null:pass

func init()->void:
	if _is_inited:return
	_is_inited=true
	#

func _get(k:StringName)->Variant:
	if !_is_inited:init()
	return read(k,null)

func _set(k:StringName,v:Variant)->bool:
	if !_is_inited:
		if k.begins_with("metadata/"):return false
		init()
	#
	write(k,v)
	if _stub!=null and !_stub._busy:_stub.broadcast(k,v)
	return true
