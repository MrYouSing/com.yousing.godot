class_name FsmAction extends FsmState

@export_group("Action")
@export var trigger:BaseTrigger

signal finished()

var character:CharacterController

func get_character()->CharacterController:
	if character!=null:return character
	if root.context is CharacterController:return root.context
	return null

func _on_init()->void:
	character=get_character()
