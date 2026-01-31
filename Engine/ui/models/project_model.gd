## A model that accesses [ProjectSettings].
class_name ProjectModel extends Resource

static var current:ProjectModel

@export_group("Project")

var _stub:ViewModel.Stub
var _keys:PackedStringArray

func refresh()->void:
	if _stub!=null:_stub.refresh()

func flush()->void:
	var f:String="override.cfg"
	ProjectSettings.save_custom(f)
	IOExtension.set_config(f,_keys,true)

func _bind(s:ViewModel.Stub)->void:
	_stub=s
	if s==null:
		LangExtension.remove_signal(ProjectSettings,&"settings_changed",refresh)
	else:
		IOExtension.get_config("override.cfg",_keys)
		LangExtension.add_signal(ProjectSettings,&"settings_changed",refresh)

func _get(k:StringName)->Variant:
	current=self
	if ProjectSettings.has_setting(k):
		var v:Variant=ProjectSettings.get_setting_with_override(k)
		match typeof(v):
			TYPE_STRING,TYPE_STRING_NAME:
				var s:String=v;if s.begins_with("uid://"):return load(s)
		return v
	return null

func _set(k:StringName,v:Variant)->bool:
	current=self
	if ProjectSettings.has_setting(k):
		ProjectSettings.set_setting(k,v)
		if !_keys.has(k):_keys.append(k)
		flush();return true
	return false
