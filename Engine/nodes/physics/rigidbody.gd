## The godot-version [url=https://docs.unity3d.com/Documentation/ScriptReference/Rigidbody.html]Rigidbody[/url].
class_name Rigidbody extends Node

const k_type_2d:int=2
static var k_classes:PackedStringArray=[
	"Node2D","RigidBody2D","CharacterBody2D",
	"Node3D","RigidBody3D","CharacterBody3D"]

@export_group("Rigidbody")
@export var root:Node
@export var auto:bool

var _type:int
var _delta:float
var _velocity:Variant

func get_velocity()->Variant:
	return _velocity

func set_velocity(v:Variant)->void:
	if auto and root!=null:root.set(&"freeze",false)
	#
	if _type<=k_type_2d:_on_2d(v)
	else:_on_3d(v)

func sleep()->void:
	if auto and root!=null:root.set(&"freeze",true)
	#
	if _type<=k_type_2d:_on_2d(Vector2.ZERO)
	else:_on_3d(Vector3.ZERO)

func _on_2d(v:Vector2)->void:
	_velocity=v;match _type:
		0:root.global_position+=v*_delta
		1:root.linear_velocity=v
		2:root.velocity=v;root.move_and_slide()

func _on_3d(v:Vector3)->void:
	_velocity=v;match _type:
		3:root.global_position+=v*_delta
		4:root.linear_velocity=v
		5:root.velocity=v;root.move_and_slide()

func _ready()->void:
	if root==null:root=self
	_delta=1.0/Engine.physics_ticks_per_second
	#
	var s:String=root.get_class()
	_type=k_classes.find(s)
	while _type<0 and not s.is_empty():
		s=ClassDB.get_parent_class(s)
		_type=k_classes.find(s)
