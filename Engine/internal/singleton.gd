## A helper class for singleton.
class_name Singleton

static func get_instance(k:StringName)->Object:
	if not Engine.has_singleton(k):return null
	else:return Engine.get_singleton(k)

static func set_instance(k:StringName,v:Object)->void:
	if v==null:Engine.unregister_singleton(k)
	else:Engine.register_singleton(k,v)

static func new_instance(k:StringName,v:Variant)->Object:
	var i:Object=null
	if v is Callable:i=v.call()
	elif v is Script:i=v.new()
	elif ClassDB.class_exists(k) and ClassDB.can_instantiate(k):
		i=ClassDB.instantiate(k)
	if i is Node:
		i.name=k
		if Application.get_frames()>0:GodotExtension.add_node(i,null,false)
		else:GodotExtension.add_node.call_deferred(i,null,false)
		if i.has_method(&"_ready"):i._ready()
	return i

static func try_instance(k:StringName,v:Variant)->Object:
	var i:Object=get_instance(k)
	if i==null:
		# Create an instance.
		i=new_instance(k,v)
		# Ensure an instance.
		if i!=null and get_instance(k)==null:
			print("Register a {0} by {1} without init()".format([k,i]))
			set_instance(k,i)
	return i

static func init_instance(k:StringName,v:Object)->bool:
	var i:Object=get_instance(k)
	if i==null:
		set_instance(k,v)
		return true
	elif i!=v:# Destroy other instance.
		GodotExtension.destroy(v)
	return false

static func exit_instance(k:StringName,v:Object)->bool:
	var i:Object=get_instance(k)
	if i==v:set_instance(k,null);return true
	else:return false
