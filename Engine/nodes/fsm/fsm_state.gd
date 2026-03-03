class_name FsmState extends FsmNode

@export_group("State")
@export var duration:float=0.0:
	set(x):_on_duration(x);duration=x
@export var transitions:Array[FsmTransition]
var root:FsmRoot

# engine methods.

func _on_duration(f:float)->void:
	pass

func _on_init()->void:
	pass

func _on_check()->bool:
	return root.check_transitions(self,transitions)

# fsm methods.

func _on_enter()->void:
	pass

func _on_tick()->void:
	pass

func _on_exit()->void:
	pass
