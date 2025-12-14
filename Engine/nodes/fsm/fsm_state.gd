class_name FsmState extends FsmNode

@export_group("State")
@export var duration:float=0.0
@export var transitions:Array[FsmTransition]
var root:FsmRoot

# engine methods.

func on_init()->void:
	pass

func on_check()->bool:
	return root.check_transitions(self,transitions)

# fsm methods.

func on_enter()->void:
	pass

func on_tick()->void:
	pass

func on_exit()->void:
	pass
