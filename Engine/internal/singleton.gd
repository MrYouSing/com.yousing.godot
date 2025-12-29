## A helper class for singleton.
class_name Singleton

static func get_instance(k:StringName)->Object:
	if !Engine.has_singleton(k):return null
	else:return Engine.get_singleton(k)

static func set_instance(k:StringName,v:Object)->void:
	if v==null:Engine.unregister_singleton(k)
	else:Engine.register_singleton(k,v)

static func new_instance(k:StringName)->Object:
	if ClassDB.class_exists(k) and ClassDB.can_instantiate(k):
		var v:Object=ClassDB.instantiate(k)
		if v is Node:
			GodotExtension.add_node(v);
			if v.has_method(&"_ready"):v._ready()
		return v
	return

static func try_instance(k:StringName,c:Callable)->Object:
	var i:Object=get_instance(k)
	if i==null:
		# Create an instance.
		if c.is_null():i=new_instance(k)
		else:i=c.call()
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

#const k_keyword:StringName=&"YouSing_@"
#static var s_create:Callable=func()->Object:
#	var i:@=@.new();i.name=k_keyword
#	GodotExtension.add_node(i,null,false)
#	i._ready();return i
#
#static var instance:@:
#	get:return Singleton.try_instance(k_keyword,s_create)
#	set(x):Singleton.set_instance(k_keyword,x)
#
#func _ready()->void:
#	if Singleton.init_instance(k_keyword,self):
#		pass
#
#func _exit_tree()->void:
#	if Singleton.exit_instance(k_keyword,self):
#		pass
