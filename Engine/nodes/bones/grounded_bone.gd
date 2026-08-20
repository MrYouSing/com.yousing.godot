## A [url=http://www.root-motion.com/finalikdox/html/page9.html]Grounder[/url] implementation for Godot.
@tool
class_name GroundedBone extends BaseBone

@export_group("Grounded")
@export var detector:BaseDetector
@export var offset:Vector3=Vector3(0.0,0.1,0.0)
@export var threshold:Vector4=Vector4(0.0,0.5,0.0,15.0)## x:Min,y:Max,z:Origin,w:Slope
@export var angle:Vector2
@export var pole:Vector3=Vector3.ZERO
@export var smooth:Vector3=Vector3.ONE*0.5## x:On,y:Off,<=0.0:Set,>0.0:Tween,z:Rot[0.0,1.0]
@export var count:Vector2i=Vector2i(3,3)## x for bones,y for nodes.
@export var bones:PackedStringArray:
	set(x):_bones.clear();bones=x
@export var nodes:Array[Node]

var _bones:PackedInt32Array
var _sides:PackedInt32Array
var _normals:PackedVector3Array
var _on_times:PackedFloat32Array
var _off_times:PackedFloat32Array

func get_time()->float:
	return Application.get_time()

func get_factor(i:int,d:float)->float:
	var t:float=-1.0;var s:float
	if _on_times[i]>=0.0:
		t=get_time()-_on_times[i]
		s=smooth.x
	elif _off_times[i]>=0.0:
		t=get_time()-_off_times[i]
		s=smooth.y
	if t>-1.0:
		if s<=0.0:return -s*d*60.0# Set influence.
		else:return clampf(t/s,0.0,1.0)# Tween influence.
	return 1.0

func safe_rotation(q:Basis)->Basis:
	if Vector3.FORWARD.dot(q*Vector3.FORWARD)<0.0:
		return Basis(Vector3.UP,PI)*MathExtension.get_heading(q)
	return q

func _on_update(c:Skeleton3D,b:int,d:float)->void:
	if c==null:return
	if detector==null:return
	#
	var n:int=bones.size()/count.x
	if _bones.is_empty():
		AnimationExtension.find_bones(c,bones,_bones)
		_sides.resize(n);_sides.fill(0)
		_normals.resize(n);_normals.fill(Vector3.UP)
		_on_times.resize(n);_on_times.fill(-1.0)
		_off_times.resize(n);_off_times.fill(-1.0)
	#
	for i in n:_on_solve(c,i,d)

func _on_solve(c:Skeleton3D,i:int,d:float)->void:
	if i<0:return
	var j:int=_bones[i*count.x+2]
	var n:Node=nodes[i*count.y+1]
	var p:Transform3D=c.global_transform
	var q:Quaternion=p.basis.get_rotation_quaternion()
	var m:Transform3D=p*c.get_bone_global_pose(j)
	var a:Transform3D=AnimationExtension.get_bone_global_change(c,j)
	var r:Quaternion=q*Quaternion.IDENTITY.slerp(a.basis.get_rotation_quaternion(),smooth.z)
	GodotExtension.set_global_transform(detector,Transform3D(r,m.origin))
	var s:int;var u:Vector3=Vector3.UP
	if _on_detect():
		var h:PhysicsExtension.HitInfo=detector.fetch(detector.target)
		var f:float=h.normal.dot(h.point+r*offset-m.origin)
		if f>=threshold.x and f<=threshold.y:
			# Side and normal.
			if f>=threshold.z:s=1
			else:s=-1
			if threshold.w!=0.0:
				if h.normal.dot(_normals[i])<=cos(threshold.w*MathExtension.k_deg_to_rad):
					_sides[i]=0
			u=h.normal
			#
			r=MathExtension.rotate_between(r*-detector.forward,h.normal)
			r=safe_rotation(r)*m.basis
			if angle.length_squared()!=0.0:r=_on_angle(c,i,q,r)
			m.basis=Basis(r)
			m.origin=h.point+(r*nodes[i*count.y+2].basis.get_rotation_quaternion())*offset
	if s!=_sides[i]:
		if s!=0:
			_on_times[i]=get_time()
			_on_ground(c,i)
			_off_times[i]=-1.0
		else:
			_off_times[i]=get_time()
			_on_raise(c,i)
			_on_times[i]=-1.0
	if pole.length_squared()>0.0:
		_on_pole(c,i)
	d=get_factor(i,d);if d<1.0:
		m=GodotExtension.get_global_transform(n).interpolate_with(m,d)
	_sides[i]=s;_normals[i]=u
	GodotExtension.set_global_transform(n,m)

func _on_detect()->bool:
	return detector.detect()

func _on_angle(c:Skeleton3D,i:int,p:Quaternion,q:Quaternion)->Quaternion:
	var b:bool=false
	var r:Quaternion=nodes[i*count.y+2].basis.get_rotation_quaternion();var s:Quaternion=r*q
	var f:float=asin(Vector3.UP.dot((p.inverse()*s)*Vector3.FORWARD))*MathExtension.k_rad_to_deg
	if f<angle.x:f=angle.x;b=true
	elif f>angle.y:f=angle.y;b=true
	if b:
		f+=asin(Vector3.UP.dot(p*Vector3.FORWARD))*MathExtension.k_rad_to_deg
		q=MathExtension.get_heading(s)
		q=Quaternion(Vector3.RIGHT,f*MathExtension.k_deg_to_rad)*q
		q=r.inverse()*q
	return q

func _on_pole(c:Skeleton3D,i:int)->void:
	var j:int=i*count.x
	var m:Transform3D=AnimationExtension.get_bone_global_pole\
		(c,_bones[j+0],_bones[j+1],_bones[j+2])
	m.origin+=m.basis*pole;m=c.global_transform*m
	GodotExtension.set_global_transform(nodes[i*count.y+0],m)

func _on_ground(c:Skeleton3D,i:int)->void:
	pass

func _on_raise(c:Skeleton3D,i:int)->void:
	pass
