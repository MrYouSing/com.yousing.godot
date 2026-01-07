## A fake [Range] that makes [ReferenceRect],[ColorRect],[TextureRect] and [NinePatchRect] as ranges.
class_name UIRect extends AbsRange

@export_group("Rect")
@export var control:Control
@export var ori_anchor:Vector2=Vector2.ZERO
@export var min_anchor:Vector2=Vector2.DOWN
@export var max_anchor:Vector2=Vector2.ONE
@export var padding:Vector4=Vector4.ZERO

func _ready()->void:
	if control==null:control=GodotExtension.assign_node(self,"Control")
	super._ready()

func _value_changed(f:float)->void:
	var rect:Control=control;if rect==null:return
	f=inverse_lerp(min_value,max_value,f)
	if is_nan(ori_anchor.x):
		rect.scale=min_anchor*f+max_anchor
	else:
		var z:Vector2=min_anchor.lerp(max_anchor,f)
		var a:Vector2=ori_anchor.min(z);z=ori_anchor.max(z);var w:Vector4=padding
		rect.set_anchor_and_offset(SIDE_LEFT,a.x,w.x,true)
		rect.set_anchor_and_offset(SIDE_RIGHT,z.x,w.z,true)
		rect.set_anchor_and_offset(SIDE_TOP,a.y,w.y,true)
		rect.set_anchor_and_offset(SIDE_BOTTOM,z.y,w.w,true)
