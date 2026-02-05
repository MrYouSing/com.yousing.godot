## A helper class that calculates a [Rect2] from [Container].
class_name UIBox extends Tickable

@export_group("Box")
@export var control:Control
@export var container:Node
@export var strict:bool
@export var count:StringName=&"get_child_count"
@export var item:StringName=&"get_child"
@export var rect:StringName=&"get_global_rect"
@export var offset:StringName=&"get_position"
@export var padding:Vector4

func _count()->int:
	var v:Variant=null
	if container.has_method(count):
		v=container.call(count)
	else:
		v=container.get(count)
	match typeof(v):
		TYPE_NIL:pass
		TYPE_INT:return v
		TYPE_STRING,TYPE_STRING_NAME:return v.length()
		_:return v.size()
	return 0

func _rect(i:int)->Rect2i:
	var r:Rect2
	if item.is_empty():
		r=container.call(rect,i)
	else:
		var o:Object=container.call(item,i)
		if o!=null:r=o.call(rect)
	return r

func _play()->void:pass

func _tick()->void:
	var r:Rect2
	if container!=null:
		var n:int=_count();
		if n>0:
			if strict:
				r=_rect(0);for i in n-1:r=r.merge(_rect(i))
			else:
				r=_rect(0).merge(_rect(n-1))
			if !offset.is_empty():r.position+=container.call(offset)
	if control!=null:
		var p:Vector2=r.position;var s:Vector2=r.size
		p.x+=padding.x;p.y+=padding.y
		s.x-=padding.x+padding.z;s.y-=padding.y+padding.w
		UITransform.set_anchor_and_offset(control,Vector2.ZERO,Vector2.ZERO,p,p+s)

func _stop()->void:pass

func _ready()->void:
	if container==null:container=GodotExtension.assign_node(self,"Container")
	if control==null:control=GodotExtension.assign_node(self,"Control")
	super._ready()
