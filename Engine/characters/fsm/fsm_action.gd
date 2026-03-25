class_name FsmAction extends FsmState

@export_group("Action")
@export var trigger:BaseTrigger

signal finished()

var character:CharacterController

func get_progress()->float:
	var t:float=duration
	if is_zero_approx(t):return 1.0
	t=root.time.x/t
	if is_zero_approx(t-1.0):return 1.0
	return t

func get_character()->CharacterController:
	if character!=null:return character
	if root.context is CharacterController:return root.context
	return null

func get_animator()->Animator:
	var c:CharacterController=get_character()
	if c==null:return null
	else:return c.animator

func _on_init()->void:
	character=get_character()
