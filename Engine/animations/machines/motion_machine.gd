## A simple implementation for [member AnimationMixer.root_motion_track].
class_name MotionMachine extends Node

@export_group("Motion")
@export var animation:AnimationMixer
@export var rigidbody:Rigidbody
@export var root:Node
@export var model:Node
@export var physics:bool=true
@export var snapshot:Snapshot
@export var album:Album

signal refreshed()

var _rotation:Quaternion
var _velocity:Vector3
# Custom
var _time:float
var _range_x:Vector4
var _curve_x:Curve
var _range_y:Vector4
var _curve_y:Curve
var _range_z:Vector4
var _curve_z:Curve
var _range_r:Vector4
var _curve_r:Curve

func set_enabled(b:bool)->void:
	set_process(b)
	set_physics_process(b and physics)

func sample_float(r:Vector4,c:Curve,t:float)->float:
	var a:bool=not r.is_zero_approx()
	var b:bool=c!=null
	if not a and not b:return 0.0
	#
	if a:t=clampf(inverse_lerp(r.x,r.z,t),0.0,1.0)
	if b:t=c.sample_baked(t)
	if a:t=r.y+(r.w-r.y)*t
	return t

func load_snapshot(s:Snapshot)->void:
	_time=0.0;snapshot=s
	_rotation=Quaternion(0.0,0.0,0.0,0.0)
	if s!=null:
		s.load(self)
	else:
		_range_x=Vector4.ZERO;_curve_x=null
		_range_y=Vector4.ZERO;_curve_y=null
		_range_z=Vector4.ZERO;_curve_z=null
		_range_r=Vector4.ZERO;_curve_r=null

func get_rotation()->Quaternion:
	if not is_zero_approx(_rotation.length_squared()):return _rotation
	var n:Node=root;if n==null:n=rigidbody.root
	return n.global_basis.get_rotation_quaternion()

func update_velocity(d:float)->void:
	_velocity=MathExtension.k_vec3_nan
	if rigidbody==null:return
	#
	var r:float=0.0
	var q:Quaternion=get_rotation()
	if snapshot!=null:
		_time+=d
		_velocity=q*Vector3(
			sample_float(_range_x,_curve_x,_time),\
			sample_float(_range_y,_curve_y,_time),\
			sample_float(_range_z,_curve_z,_time)\
		)
		r=sample_float(_range_r,_curve_r,_time)
	elif animation!=null:
		_velocity=(q*animation.get_root_motion_position())/d
	GodotExtension.set_global_rotation(model,r)

func update_motion(d:float)->void:
	if is_nan(_velocity.x):return
	if rigidbody!=null:
		rigidbody._delta=d
		rigidbody.set_velocity(_velocity)

func _on_toggle(c:Object,b:bool)->void:
	set_enabled(not b)

func _on_blend(c:Object,f:float)->void:
	if snapshot==null:return
	var d:float=f-_time;update_velocity(d)
	if not physics:update_motion(d)

func _on_event(c:Object,e:StringName)->void:
	if album!=null:
		var s:Snapshot=album.load(e)
		if s!=snapshot:
			load_snapshot(null)
			if s!=null:
				load_snapshot(s)
				set_process(false)
				set_physics_process(physics)
				refreshed.emit()
			else:
				set_enabled(false)

func _ready()->void:
	#if animation==null:
	#	animation=GodotExtension.assign_node(self,"AnimationTree") as AnimationMixer
	if rigidbody==null:
		rigidbody=GodotExtension.assign_node(self,"Rigidbody") as Rigidbody
	load_snapshot(snapshot)
	set_physics_process(is_processing() and physics)

func _process(d:float)->void:
	update_velocity(d)
	if not physics:update_motion(d)

func _physics_process(d:float)->void:
	update_motion(d)
