## A virtual camera for state management.
class_name VirCamera extends Node

static var instances:Array[VirCamera]=LangExtension.alloc_array(VirCamera,32)

@export_group("Camera")
@export var enabled:bool:
	set(x):enabled=x;if is_node_ready():set_enabled(x)
@export var index:int
@export var camera:Node
@export var lens:Lens
@export var transitions:TransitionLibrary

func set_enabled(b:bool)->void:
	var o:VirCamera=instances[index]
	if b:
		_on_show()
		if o!=null:o.set_enabled(false)
		instances[index]=self
	else:
		if o!=self:return
		_on_hide()
		instances[index]=null

func _on_show()->void:
	var c:Node;var n:Node
	if camera!=null:
		c=camera;n=camera
	else:
		var s:SubCamera=SubCamera.instances[index]
		c=s.camera
		if s.root!=null:n=s.root
		else:n=c
	if c==null:return
	#
	var m:Transform3D=GodotExtension.get_global_transform(self)
	var x:Transition=null;if transitions!=null:
		var o:VirCamera=instances[index]
		if o!=null:x=transitions.eval(o.name,name)
		else:x=transitions.eval(&"*",name)
	#
	if x==null or x.instant():
		Tweenable.kill_tween(c)
		GodotExtension.set_global_transform(n,m)
		if lens!=null:lens.direct_to_camera_3d(c)
		_on_done()
	else:
		var t:Tween=Tweenable.make_tween(c)
		x.to_tween(t,n,^"global_position",m.origin)
		x.to_tween(t,n,^"global_basis",m.basis)
		if lens!=null:Transition.current=c;lens.tween_to_camera_3d(c,t,x)
		t.finished.connect(_on_done)

func _on_done()->void:
	pass

func _on_hide()->void:
	pass

func _ready()->void:
	_start.call_deferred()

func _start()->void:
	if enabled:set_enabled(true)
