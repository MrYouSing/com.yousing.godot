## The godot-version [url=https://docs.unity3d.com/Packages/com.unity.xr.interaction.toolkit@3.5/api/UnityEngine.XR.Interaction.Toolkit.Interactors.XRBaseInteractor.html]XRBaseInteractor[url].
class_name BaseInteractor extends Node

@export_group("Interact")
@export var root:Node
@export var radius:float=0.5
@export var height:float=2.0
@export var angle:float=45.0
@export var margin:float=0.04

var item:BaseInteractable
var items:Array[BaseInteractable]
var _origin:Vector3
var _direction:Vector3
var _cos:float=NAN

func set_enabled(b:bool)->void:
	for it in items:
		if it==null:continue
		it._on_miss(self)
		it.items.erase(self)
	set_process(b);set(&"visible",b)

func update_shape()->void:
	var t:Transform3D=GodotExtension.get_global_transform(root)
	_origin=t.origin;_direction=(t.basis*Vector3.MODEL_FRONT)
	_direction.y=0.0;_direction=_direction.normalized()
	if angle>0.0:_cos=cos(angle*MathExtension.k_deg_to_rad)

func contain(i:BaseInteractable)->bool:
	if i!=null and i.detector!=null:
		if i.detetor.targets.has(root):
			var v:Vector3=i.get_point()-_origin
			if height>0.0:if v.y<0.0 or v.y>height:return false
			v.y=0.0
			if radius>0.0:if v.length_squared()>radius*radius:return false
			if not is_nan(_cos):if v.normalized().dot(_direction)<_cos:return false
			return true
	return false

func compare(a:BaseInteractable,b:BaseInteractable)->bool:
	var u:Vector3=a.get_point()-_origin
	var v:Vector3=b.get_point()-_origin
	u.y=0.0;v.y=0.0
	match MathExtension.vec3_compare(u,v,margin):
		-1:return true
		1:return false
	if u.normalized().dot(_direction)>v.normalized().dot(_direction):
		return true
	return false

func fetch(a:Array[BaseInteractable],b:bool=false)->void:
	update_shape()
	for it in items:if contain(it):a.append(it)
	if b:a.sort_custom(compare)

func _on_find(i:BaseInteractable)->void:
	if i==null:return
	if not items.has(i):items.append(i)

func _on_miss(i:BaseInteractable)->void:
	if i==null:return
	items.erase(i)
