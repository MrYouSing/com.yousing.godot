## A procedural audio for footsteps.
class_name Footstep extends Audio

@export_group("Footstep")
@export var material:StringName
@export var speed:float=1.0
@export var start:Vector2=Vector2(0.5,0.0)
@export var next:Vector2=Vector2(0.5,0.0)
@export var scale:Vector2=Vector2.ZERO
@export var bones:Array[Node]

signal on_footstep(n:Node)

var time:float=-1.0
var timestamp:int=-1

func interval(d:Vector2)->float:
	if d.x!=0.0:
		if d.y!=0.0:return randf_range(d.x,d.y)
		else:return d.x
	return -1.0

func set_enabled(b:bool)->void:
	if is_processing()==b:return
	set_process(b)
	#
	var n:int=Application.get_frames()
	if b:
		if n!=timestamp:time=interval(start)
		else:pass#print("Re-active at the same frame.")#
	else:
		timestamp=n

func get_foot()->Node:
	match bones.size():
		1:
			return bones[0]
		3:
			var o:Node=bones[0];var l:Node=bones[1];var r:Node=bones[2]
			var x:Vector3=l.global_position;var y:Vector3=r.global_position;var z:Vector3=o.global_position
			x-=z;y-=z;z=MathExtension.get_heading(o.global_basis)*Vector3.BACK
			if x.dot(z)>=y.dot(z):return bones[1]
			else:return bones[2]
	return null

func _ready()->void:
	set_enabled(false)

func _process(delta:float)->void:
	if time<0.0:return
	time-=delta*speed
	if time<=0.0:_footstep()

func _material(x:StringName)->void:
	material=x

func _footstep()->void:
	open(material);play()
	if not scale.is_zero_approx():volume=interval(scale)
	if on_footstep.has_connections():on_footstep.emit(get_foot())
	# Next
	time+=interval(next)
