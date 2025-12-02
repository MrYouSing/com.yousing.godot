class_name FsmAction extends FsmState

var character:CharacterController

func get_character()->CharacterController:
	if character!=null:return character
	if root.context is CharacterController:return root.context
	return null

func on_init()->void:
	character=get_character()
