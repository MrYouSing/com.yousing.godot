/* <!-- Macro.Table Types
bool,bool,
int,int,
float,float,
String,string,
Vector4,vector,
 Macro.End --> */

/* <!-- Macro.Call  Types
@export var dict_{1}:Dictionary[StringName,{0}]

static func get_{1}(k:StringName,v:{0})->{0}:
	if current!=null:return current.dict_{1}.get(k,v)
	else:return Application.get_config().get_value(slot,k,v)

static func set_{1}(k:StringName,v:{0})->void:
	if current!=null:current.dict_{1}.set(k,v)
	else:Application.get_config().set_value(slot,k,v)

 Macro.End --> */
/* <!-- Macro.Patch
save_data.gd,AutoGen
 Macro.End --> */

/* <!-- Macro.Call  Types
		&"{0}":dict_{1},
 Macro.End --> */
/* <!-- Macro.Patch
save_data.gd,Save
 Macro.End --> */

/* <!-- Macro.Call  Types
	if m.has(&"{0}"):dict_{1}.assign(m.{0})
	else:dict_{1}.clear()
 Macro.End --> */
/* <!-- Macro.Patch
save_data.gd,Load
 Macro.End --> */