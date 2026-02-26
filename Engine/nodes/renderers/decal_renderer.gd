## A helper class for drawing [Decal].
class_name DecalRenderer extends Node

@export_group("Decal")
@export var capacity:int
@export var threshold:float=0.01
@export var duration:Vector2
@export var prefabs:Array[Node]
@export_group("Transform")
@export var detector:BaseDetector
@export var depth:float
@export var axis:Vector3=Vector3.UP
@export var angle:Vector2=Vector2(0.0,360.0)
@export var zoom:Vector2=Vector2.ONE

var _point:Vector3
var _actors:Array[Node]
var _calls:PackedInt32Array

func kill(n:Node)->void:
	var i:int=_actors.find(n)
	if i>=0:
		if Juggler.exists:Juggler.instance.kill_call(_calls[i])
		if n.has_method(&"_on_kill"):n._on_kill()
		elif Stage.exists:Stage.instance.despawn(n)
		_actors.remove_at(i);_calls.remove_at(i)

func create(m:Variant)->Node:
	var n:Node=prefabs[randi()%prefabs.size()]
	if n!=null:
		n=Stage.instance.spawn(n,null,m)
		_actors.append(n)
		if duration.is_zero_approx():_calls.append(Juggler.k_invalid_id)
		else:_calls.append(Juggler.instance.delay_call(kill,[n],randf_range(duration.x,duration.y)))
	return n

func transform(p:Vector3,v:Vector3,a:float,s:float)->Variant:
	if prefabs[0] is Node3D:
		var q:Basis=Basis(axis,a).rotated(Vector3.RIGHT,PI*0.5).scaled_local(Vector3.ONE*s)
		return Transform3D(MathExtension.aiming_at(v)*q,p)
	else:
		return Transform2D(a,Vector2.ONE*s,0.0,Vector2(p.x,p.y))

func find(v:Vector3)->Node:
	var n:Node=null;var p:Vector3
	var t:float=threshold*threshold
	var m:float=2.0*t;var d:float
	for it in _actors:
		if it==null:continue;
		p=GodotExtension.get_global_position(it)
		d=(p-v).length_squared()
		if d<t or is_zero_approx(d-t):if d<m:m=d;n=it
	return n

func draw()->void:
	var p:Vector3=GodotExtension.get_global_position(self)
	var v:Vector3=GodotExtension.get_global_transform(self).basis*Vector3.BACK
	var a:float=randf_range(angle.x,angle.y)*MathExtension.k_deg_to_rad
	var s:float=randf_range(zoom.x,zoom.y)
	if detector!=null and detector.detect():
		var h:Physics.HitInfo=detector.fetch(detector.target)
		v=h.normal;p=h.point
	# Clean and create.
	var n:Node=find(p);if n!=null:kill(n)
	if capacity>0 and _actors.size()>=capacity:kill(_actors[0])
	_point=p;create(transform(p+v*depth,v,a,s))
