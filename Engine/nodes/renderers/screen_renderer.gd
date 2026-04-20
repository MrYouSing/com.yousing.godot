## An overlay renderer for screen effects.
class_name ScreenRenderer extends Node

static var current:ScreenRenderer

@export_group("Screen")
@export_range(0.0,1.0,0.001)var weight:float=1.0:
	set(x):
		weight=x
		_on_sample(_from_type,_from_obj,1.0-x)
		_on_sample(_to_type,_to_obj,x)
@export var fade:float=1.0
@export var transitions:TransitionLibrary
@export var nodes:Array[Node]

signal finished()

var _state:StringName
var _from_type:int
var _from_obj:Object
var _to_type:int
var _to_obj:Object

func get_type(o:Object)->int:
	return 0

func set_state(k:StringName,o:Object)->void:
	if k==_state and o==_to_obj:return
	#
	_on_sample(_from_type,_from_obj,0.0)
	_on_swap();_to_type=get_type(o);_to_obj=o
	var x:Transition
	if transitions!=null:x=transitions.eval(_state,k)
	_state=k
	#
	if (x==null or x.instant()) and fade==0.0:
		weight=1.0
		_on_finish()
	else:
		weight=0.0
		var t:Tween=Tweenable.make_tween(self)
		Tweenable.set_always(t,process_mode)
		if x!=null:x.to_tween(t,self,^"weight",1.0)
		else:t.tween_property(self,^"weight",1.0,fade)
		t.finished.connect(_on_finish)

func set_color(k:StringName,c:Color)->Object:
	var n:Node=nodes[0];if n==_to_obj:n=nodes[1]
	n.self_modulate=c;n.set(&"texture",TextureLoader.load_from_cache("$white"))
	GodotExtension.move_node(n,-1);set_state(k,n);return n

func set_texture(k:StringName,t:Texture)->Object:
	var n:Node=nodes[0];if n==_to_obj:n=nodes[1]
	n.self_modulate=Color.WHITE;n.set(&"texture",t)
	n.set(&"region_rect",Rect2())
	GodotExtension.move_node(n,-1);set_state(k,n);return n

func _on_swap()->void:
	var i:int=_from_type;_from_type=_to_type;_to_type=i
	var o:Object=_from_obj;_from_obj=_to_obj;_to_obj=o

func _on_sample(i:int,o:Object,f:float)->void:
	if o==null:return
	match i:
		0:
			var c:Color=o.modulate
			c.a=f;o.modulate=c

func _on_finish()->void:
	finished.emit()#;LangExtension.clear_signal(finished)

func _ready()->void:
	if current==null:current=self

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	if self==current:current=null
