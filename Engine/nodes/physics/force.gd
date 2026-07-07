## A helper class for driving [Rigidbody].
class_name Force extends Tickable

static func get_force(r:Rigidbody,p:NodePath,s:Script=null)->Force:
	var f:Force=null
	if r!=null:
		f=r.get_node_or_null(p) as Force
		if f==null and s!=null:
			f=s.new();f.name=StringName(p);f.rigidbody=r
			GodotExtension.add_node(f,r,false)
	return f

@export_group("Force")
@export var rigidbody:Rigidbody
@export var duration:float=-1.0

signal finished()

var _total:float=-1.0
var _offset:Variant=null
var _model:Node

func _play()->void:
	_total=0.0
	_offset=null
	if rigidbody==null:
		rigidbody=get_parent()
		if rigidbody==null:return
	if _model==null:
		var n:Node=rigidbody.root.get_node_or_null(^"Model")
		if n==null:_model=rigidbody
		else:_model=n

func _tick()->void:
	_total+=_step
	if rigidbody!=null:
		if _offset!=null:rigidbody.sweep(rigidbody.root.global_position+_offset)
	if duration>=0.0 and _total>=duration:
		finished.emit()
		set_enabled(false)

func _stop()->void:
	_total=-1.0
	_offset=null
	_model=null

func _on_enabled(b:bool)->void:
	set(&"visible",b);
	set_process(false)
	set_physics_process(b)

func _rate()->void:
	if _step<0.0:_step=-_step/Engine.physics_ticks_per_second
	else:_step=MathExtension.time_delta(rate)

func _physics_process(d:float)->void:
	if _step==0.0:_total+=d
	_process(d)
