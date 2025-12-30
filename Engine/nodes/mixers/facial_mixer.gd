## A composite mixer for facial mocap,like [url=https://developer.apple.com/documentation/arkit/arfaceanchor]ARKit[/url].
@tool
class_name FacialMixer extends CompositeMixer

@export_group("Facial")
@export var targets:Array[MeshInstance3D]
@export var shapes:Array[StringName]
@export_range(0.0,1.0,0.001,"or_greater","or_less")
var weights:Array[float]
@export_tool_button("Setup")var _setup:Callable=setup

var dirty:bool

func setup()->void:
	if shapes.is_empty():
		if targets.is_empty():return
		GodotExtension.get_blend_shape_names(targets[0],shapes)
	if mixers.is_empty():
		var m:MorphMixer;for it in shapes:
			m=MorphMixer.new();
			m.name=it;m.shape=it
			m.targets.append_array(targets)
			#
			GodotExtension.add_node(m,self,false)
			m.owner=self;mixers.append(m)
	else:
		for it in mixers:if it is MorphMixer:
			if !it.is_valid():it.targets=targets;it.shapes.clear()
	var n:int=mixers.size()
	if weights.size()<n:weights.resize(n)
	#
	dirty=true

func sample(f:float)->void:
	if Engine.is_editor_hint() and mixers.is_empty():setup()
	flush(weights);dirty=false

func _ready()->void:
	setup()

func _process(delta:float)->void:
	if Engine.is_editor_hint() and !mixers.is_empty():dirty=true
	if dirty:sample(weight)
