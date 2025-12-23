## An additional info asset for animator state machines.
class_name AnimatorLayer extends Resource

@export_group("Layer")
@export var name:StringName
@export var exit:StringName
@export var exit_times:Dictionary[StringName,Variant]
@export var exit_funcs:Dictionary[StringName,Variant]
