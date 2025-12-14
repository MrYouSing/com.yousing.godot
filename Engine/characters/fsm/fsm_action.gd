class_name FsmAction extends FsmState

@export var view:NodePath

var character:CharacterController
var actor:Node

func get_character()->CharacterController:
	if character!=null:return character
	if root.context is CharacterController:return root.context
	return null

func on_init()->void:
	character=get_character()
	if !view.is_empty():actor=get_node_or_null(view)
