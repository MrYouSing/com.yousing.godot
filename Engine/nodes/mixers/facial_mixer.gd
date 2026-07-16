## A composite mixer for facial mocap,like [url=https://developer.apple.com/documentation/arkit/arfaceanchor]ARKit[/url].
@tool
class_name FacialMixer extends CompositeMixer

@export_group("Facial")
@export_range(0.0,1.0,0.001) var smooth:float=0.5
@export var targets:Array[MeshInstance3D]
@export var shapes:Array[StringName]
@export_range(0.0,1.0,0.001,"or_greater","or_less")
var weights:PackedFloat32Array
@export_tool_button("Setup")var _setup:Callable=setup

var dirty:bool

func setup()->void:
	if shapes.is_empty():
		if targets.is_empty():return
		AnimationExtension.get_blend_shape_names(targets[0],shapes)
	if mixers.is_empty():
		var m:MorphMixer;for it in shapes:
			m=MorphMixer.new()
			m.name=it;m.shape=it
			m.targets=targets
			#
			GodotExtension.add_node(m,self,false)
			m.owner=self;mixers.append(m)
			GodotExtension.editor_dirty(m)
	else:
		for it in mixers:if it is MorphMixer:
			if not it.is_valid():it.targets=targets;it.shapes.clear()
	var n:int=mixers.size()
	if weights.size()<n:weights.resize(n)
	#
	dirty=true

func sample(f:float)->void:
	if Engine.is_editor_hint() and mixers.is_empty():setup()
	super.flush(weights);dirty=false

func index_of(k:StringName)->int:
	return shapes.find(k)

func flush(a:PackedFloat32Array)->void:
	set_process(false)
	for i in a.size():weights[i]=lerpf(weights[i],a[i],smooth)
	super.flush(weights);dirty=false

func _ready()->void:
	if Engine.is_editor_hint():return
	if mixers.size()>0:if mixers[0]==null:mixers.clear()
	setup()

func _process(delta:float)->void:
	if Engine.is_editor_hint() and not mixers.is_empty():dirty=true
	if dirty:sample(weight)
