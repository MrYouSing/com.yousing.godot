## A bubble animation for ui.
class_name UIBubble extends UIAnimation

@export_group("UI")
@export var view:Node
@export var content:StringName=&"text"
@export var duration:float=1.0
@export var alpha:Curve
@export_group("Bubble")
@export var gizmo:UIGizmo
@export var point:Vector3
@export var normal:Vector3=Vector3.UP
@export var height:float=1.0
@export var curve:Curve

var _node:Node

func stop()->void:
	if view==null or gizmo==null:return
	gizmo.set_enabled(false)
	Tweenable.kill_tween(self)
	super.stop()

func make_bubble(n:Node,p:Vector3,v:Variant)->void:
	if view==null or gizmo==null:return
	_node=n;point=p
	#
	if gizmo.actor==null:
		var a:Node3D=Node3D.new();a.name=name+".Actor"
		GodotExtension.add_node(a,null,false)
		gizmo.actor=a
	gizmo.set_enabled(true)
	view.set(content,v)
	GodotExtension.move_node(gizmo.control,-1)
	_on_sample(0.0)
	#
	var t:Tween=Tweenable.make_tween(self)
	t.tween_method(_on_sample,0.0,1.0,duration)
	t.finished.connect(stop)
	#
	play()

func _on_animate(...a:Array)->void:
	match a.size():
		3:make_bubble(a[0],a[1],a[2])
		_:stop()

func _on_sample(f:float)->void:
	if alpha!=null:
		var a:float=alpha.sample_baked(f)
		if view.has_method(&"_on_blend"):
			view._on_blend(self,a)
		else:
			gizmo.control.modulate=Color(gizmo.control.modulate,a)
	#
	if curve!=null:f=curve.sample_baked(f)
	var p:Vector3=point;if _node!=null:p=GodotExtension.get_global_transform(_node)*p
	p+=normal*(height*f);GodotExtension.set_global_position(gizmo.actor,p)
