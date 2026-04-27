## A helper animation for displaying progress.
class_name UIProgress extends UIAnimation

@export_group("Progress")
@export var target:Node
@export var property:StringName=&"progress"
@export_group("UI")
@export var view:Node
@export var slider:Node
@export var label:Node
@export var format:String="%f%%"

var _progress:float=-1.0

func stop()->void:
	set_process(false)
	super.stop()
	#
	GodotExtension.set_enabled(view,true)

func play()->void:
	set_process(true)
	_progress=-1.0
	#
	GodotExtension.set_enabled(view,false)
	_on_progress(0.0)

func make_progress(t:Node,p:StringName,c:Callable)->void:
	target=t;property=p
	if c.is_valid():finished.connect(c,CONNECT_ONE_SHOT)
	play()

func _on_animate(...a:Array)->void:
	match a.size():
		2:make_progress(a[0],a[1],LangExtension.k_empty_callable)
		3:make_progress(a[0],a[1],a[2])
		_:stop()

func _on_progress(f:float)->void:
	if label!=null:label.set(&"text",format%(f*100.0))
	if slider!=null:slider.value=f

func _ready()->void:
	super._ready()
	if target==null:stop()

func _process(d:float)->void:
	var f:float=1.0
	if target!=null:f=target.get(property)
	if _progress<0.0:_started()
	_progress=f;_on_progress(f)
	if f>=1.0:stop()
