## A procedural audio for footsteps.
class_name Footstep extends Audio

@export_group("Motor")
@export var motor:Node
@export var velocity:StringName
@export var threshold:float
@export var speed:float=1.0
@export_group("Footstep")
@export var material:String
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

func _moving()->bool:
	if motor!=null:
		var f:float=motor.get(velocity).length_squared()
		if f>=threshold*threshold:
			if time<0.0:time=interval(start)
		else:
			if time>=0.0:pass
			time=-1.0;return false
	return true

func _material(x:StringName)->void:
	material=x

func _footstep()->void:
	open(material);play()
	if not scale.is_zero_approx():volume=interval(scale)
	if on_footstep.has_connections():on_footstep.emit(get_foot())
	# Next
	time+=interval(next)

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	match typeof(v):
		TYPE_NIL:
			set_enabled(false)
		TYPE_STRING,TYPE_STRING_NAME:
			set_enabled(false)
			var s:String=v
			open(s%material);play()
		TYPE_DICTIONARY:
			var d:Dictionary=v
			if d.has(&"start"):start=d.start
			if d.has(&"next"):next=d.next
			if d.has(&"scale"):scale=d.scale
			set_process(false);set_enabled(true)

func _ready()->void:
	if motor==null:set_enabled(false)

func _process(delta:float)->void:
	if not _moving():return
	time-=delta*speed
	if time<=0.0:_footstep()
