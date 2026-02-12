## A helper class that adds ui gizmos from world objects.
class_name UIGizmo extends Node

@export_group("Gizmo")
@export var camera:Camera3D
@export var actor:Node3D
@export var offset:Vector3
@export var range:Vector2
@export var control:Control
@export var pivot:Vector2
@export var rotated:bool
@export var scale_remap:Vector4=Vector4.ZERO
@export var scale_curve:Curve

func _ready()->void:
	if camera==null:camera=UIManager.instance.camera
	if control==null:control=GodotExtension.assign_node(self,"Control")

func _process(delta:float)->void:
	if camera==null or actor==null or control==null:return
	#
	var m:Transform3D=actor.global_transform
	var v:Vector3=m*offset;var u:Vector2
	var s:Vector2=Application.get_resolution()
	var z:float=(camera.get_camera_transform().inverse()*v).z
	if z<0.0:u=camera.unproject_position(v);z*=-1.0
	else:u=UITransform.k_hidden_pos;z=-1.0
	#
	update_control(u,z,s)

func update_visible(v:int)->bool:
	if control!=null:control.visible=v>=0
	return v>=0

func update_control(u:Vector2,z:float,s:Vector2)->void:
	var c:Vector2=range
	if not c.is_zero_approx():if z<c.x or z>c.y:
		if not update_visible(-1):return
	#
	c=s*0.5
	update_scale(z)
	update_rotation(u,c)
	update_position(u,z,s)

func update_position(u:Vector2,z:float,s:Vector2)->void:
	if control==null:return
	#
	if z>=0.0:
		var a:Vector2=(control.size*control.scale)*0.5;s+=a;a*=-1.0
		if u.x<a.x or u.y<a.y or u.x>s.x or u.y>s.y:
			if not update_visible(-3):return
		update_visible(0);u+=pivot
	else:
		if not update_visible(-2):return
	control.global_position=UITransform.get_position(control,u)

func update_rotation(u:Vector2,c:Vector2)->void:
	if control==null or not rotated:return
	#
	control.rotation=MathExtension.clocking_at(u-c)

func update_scale(z:float)->void:
	if control==null:return
	#
	if scale_remap.is_zero_approx():
		if scale_curve!=null:z=scale_curve.sample_baked(z)
		else:z=1.0
	else:
		z=MathExtension.float_remap(z,scale_remap)
		if scale_curve!=null:z=scale_curve.sample_baked(z)
	control.scale=Vector2.ONE*z
