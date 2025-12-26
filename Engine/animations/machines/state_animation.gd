## A simple animation by states and tween.
class_name StateAnimation extends StateMachine

@export_group("Animation")
@export var exits:Array[StringName]

func exit()->void:stop_tween();set_state(idle)

func _on_animation(a:Tween,t:Transition,o:Object,d:Dictionary)->void:
	if o==null or d==null:return
	Transition.current=o;for k in d:t.to_tween(a,o,k,d.get(k))
	
func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	super._on_state(c,k,v,t)
	#
	if typeof(v)==TYPE_DICTIONARY:
		var d:Dictionary=v as Dictionary;
		if tween==null:tween=play_tween()
		for s in d:_on_animation(tween,t,get_node_or_null(s),d.get(s))
		if exits.has(k):tween.finished.connect(exit)
		else:tween.finished.connect(stop_tween)
