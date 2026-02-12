## A custom [SpringArm3D].
class_name RaycastNode extends RaycastDetector

@export_group("Node")
@export var node:Node
@export var normal:Vector3=Vector3.UP
@export var orientation:Vector3=Vector3.ZERO
@export var smooth:Vector2=Vector2(-1.0,60.0)

var _done:bool
var _position:Vector3
var _rotation:Basis

func _on_find_hit(d:Dictionary)->void:
	super._on_find_hit(d)
	if not d.is_empty():
		_done=true;_position=d.position
		_on_plane(d.normal)

func _on_miss_hit(d:Dictionary)->void:
	if not d.is_empty():
		_done=true;_position=_origin+_direction*distance.x

func _on_plane(n:Vector3)->void:
	if normal.is_zero_approx():
		node.basis=Quaternion.IDENTITY
	else:
		if n.is_zero_approx():n=-_direction
		node.global_basis=MathExtension.reflecting_to(_direction,n,normal,_rotation)

func _ready()->void:
	if node==null:node=get_parent().get_child(get_index()+1)
	_rotation=Basis.from_euler(orientation*MathExtension.k_deg_to_rad)
	_process(-1.0)

func _process(delta:float)->void:
	var p:Vector3=node.global_position
	_done=false;detect();if not _done:
		_position=_origin+_direction*distance.y
		_on_plane(Vector3.ZERO)
	if delta<0.0:node.global_position=_position
	else:node.global_position=MathExtension.vec3_lerp(p,_position,smooth,delta)
