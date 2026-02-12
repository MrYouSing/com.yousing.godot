class_name FsmAction extends FsmState

@export_group("Action")
@export var view:NodePath
@export var trigger:BaseTrigger

var character:CharacterController
var actor:Node

func get_character()->CharacterController:
	if character!=null:return character
	if root.context is CharacterController:return root.context
	return null

func _on_init()->void:
	character=get_character()
	if not view.is_empty():actor=get_node_or_null(view)
