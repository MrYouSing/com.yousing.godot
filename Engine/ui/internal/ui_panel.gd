## A container class for ui system.
@tool
class_name UIPanel extends Actor

@export_group("Panel")
@export var path:StringName
@export var canvas:CanvasItem
@export_range(0.0,1.0,0.001)var alpha:float=1.0:
	set(x):alpha=x;if canvas!=null:canvas.modulate=Color(canvas.modulate,x)
@export var fade_time:Vector4=Vector4(0.0,1.0,0.0,1.0)
@export var fade_in:BaseMixer
@export var fade_out:BaseMixer

var _faded:bool
var _shown:bool

var busy:bool:
	get=is_busy,set=set_busy
func is_busy()->bool:
	if busy:return tween!=null and tween.is_valid()
	else:return false
func set_busy(b:bool)->void:
	busy=b;if !b:stop_tween()
	if get_meta(&"global_busy",false):UIManager.instance.set_busy(b)

func set_enabled(b:bool)->void:
	_shown=b;if busy:return
	#
	if _faded:
		if b:begin_fade_in()
		else:begin_fade_out()
	else:
		super.set_enabled(_shown)

func _ready()->void:
	if !path.is_empty():UIManager.register(path,self)
	if canvas==null:canvas=GodotExtension.assign_node(self,"CanvasItem")
	#
	_faded=canvas!=null or fade_in!=null or fade_out!=null
	alpha=alpha

func _exit_tree()->void:
	if !path.is_empty():UIManager.register(path,null)

func do_fade(t:Tween,m:BaseMixer,v:float,w:float=0.0,d:float=1.0)->Tween:
	busy=true;t.set_ignore_time_scale(true)
	if w>0.0:t.tween_interval(w)
	if m!=null:t.tween_property(m,^"weight",v,MathExtension.time_fade(m.weight,v,d))
	elif canvas!=null:t.tween_property(self,^"alpha",v,MathExtension.time_fade(alpha,v,d))
	return t

func begin_fade_in()->void:
	super.set_enabled(true)
	var m:BaseMixer=fade_in;if m==null:m=fade_out
	do_fade(play_tween(),m,1.0,fade_time.x,fade_time.y).finished.connect(end_fade_in)

func end_fade_in()->void:
	busy=false
	if !_shown:set_enabled(false)

func begin_fade_out()->void:
	var m:BaseMixer=fade_out;if m==null:m=fade_in
	do_fade(play_tween(),m,0.0,fade_time.z,fade_time.w).finished.connect(end_fade_out)

func end_fade_out()->void:
	busy=false
	if _shown:set_enabled(true)
	else:super.set_enabled(false)
