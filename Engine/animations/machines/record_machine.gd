## A helper class for recording objects.
class_name RecordMachine extends Tickable

@export_group("Record")
@export_enum(
	"Default","Ring"
)var mode:int
@export var node:Node
@export var resource:Resource
@export var duration:float=1.0

signal finished()

var target:Object
var total:float=-1.0
var buffer:Array
var ring:Collections.Ring=null

func frames()->Array:
	match mode:
		0:return buffer
		1:return ring.array
		_:return LangExtension.k_empty_array

func sample()->Variant:
	if target!=null:return target.sample()
	else:return null

func _rate()->void:
	super._rate()
	var c:int=roundi(duration/_step)
	match mode:
		0:
			buffer.clear()
		1:
			if ring==null:ring=Collections.Ring.new(c)
			elif ring.capacity!=c:ring._init(c)

func _play()->void:
	total=0.0
	match mode:
		0:buffer.clear()
		1:if ring!=null:ring.index=-1
	if target==null:
		if node!=null:target=node
		elif resource!=null:target=resource
		if target!=null and not target.has_method(&"sample"):
			target=null

func _tick()->void:
	total+=_step
	match mode:
		0:
			buffer.append(sample())
			if duration>0.0:
				if total>duration:
					finished.emit()
					set_enabled(false)
		1:
			var v:Variant=sample()
			if v!=null:ring.push(v)

func _stop()->void:
	total=-1.0
	target=null
