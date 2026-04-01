## The godot-version [url=https://docs.unity3d.com/Packages/com.unity.xr.interaction.toolkit@3.5/api/UnityEngine.XR.Interaction.Toolkit.Interactables.XRBaseInteractable.html]XRBaseInteractable[url].
class_name BaseInteractable extends Tickable

static var current:BaseInteractable

@export_group("Interact")
@export var path:NodePath=^"Main/Interactor"
@export var shape:Node
@export var detector:BaseDetector

var items:Array[BaseInteractor]
var cancel:int

func get_point()->Vector3:
	if shape!=null:return GodotExtension.get_global_position(shape)
	else:return GodotExtension.get_global_position(self)

func to_interactor(n:Node)->BaseInteractor:
	if n==null:return null
	var i:BaseInteractor=n as BaseInteractor
	if i==null:return n.get_node_or_null(path) as BaseInteractor
	return i

func find_item(a:Array[Object],i:BaseInteractor)->Object:
	for it in a:
		if it==null:continue
		if it==i or it.is_ancestor_of(i):return it
	return null

func _play()->void:
	pass

func _tick()->void:
	if detector!=null:
		detector.detect()
		var c:BaseInteractor
		var i:int=0;var m:int=items.size();while i<m:
			c=items[i]
			if find_item(detector.targets,c)==null:
				_on_miss(c);c._on_miss(self)
				items.remove_at(i);i-=1;m-=1
			i+=1
		for it in detector.targets:
			c=to_interactor(it)
			if c==null:continue
			if not items.has(c):
				cancel=0
				_on_find(c);c._on_find(self)
				if cancel==-1:return
				if cancel==0:items.append(c)

func _stop()->void:
	for it in items:
		if it!=null:_on_miss(it);it._on_miss(self)
	items.clear()

func _on_find(i:BaseInteractor)->void:
	pass

func _on_miss(i:BaseInteractor)->void:
	pass

func _ready()->void:
	super._ready()
	if shape==null:shape=GodotExtension.assign_node(self,"Shape")
