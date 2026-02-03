## A model that accesses [ProjectSettings].
class_name ProjectModel extends AbsModel

static var current:ProjectModel

@export_group("Project")

var _keys:PackedStringArray

func refresh()->void:
	if current!=self:return
	var k:PackedStringArray=ProjectSettings.get_changed_settings()
	LangExtension.remove_strings(k,_keys)
	if _stub!=null:for it in k:_stub.verify(it)

func flush()->void:
	if current!=self:current=self;return
	var f:String="override.cfg"
	ProjectSettings.save_custom(f)
	IOExtension.set_config(f,_keys,true)

func _bind(s:ViewModel.Stub)->void:
	_stub=s
	if s==null:LangExtension.remove_signal(ProjectSettings,&"settings_changed",refresh)
	else:LangExtension.add_signal(ProjectSettings,&"settings_changed",refresh)

func read(k:StringName,v:Variant=null)->Variant:
	if ProjectSettings.has_setting(k):
		v=ProjectSettings.get_setting_with_override(k)
		match typeof(v):
			TYPE_STRING,TYPE_STRING_NAME:
				var s:String=v;if s.begins_with("uid://"):v=load(s)
	return v

func write(k:StringName,v:Variant)->void:
	if ProjectSettings.has_setting(k):
		ProjectSettings.set_setting(k,v)
		if !_keys.has(k):_keys.append(k)
		flush()

func init()->void:
	if _is_inited:return
	super.init()
	_keys.clear();IOExtension.get_config("override.cfg",_keys)
