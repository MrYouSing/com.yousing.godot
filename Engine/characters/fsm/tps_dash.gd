class_name TpsDash extends FsmDash

@export_group("TPS")
@export var head:Node

var _camera:TpsCamera
var _head:Node

func _on_init()->void:
	super._on_init()
	var c:TpsController=get_character()
	if c!=null:
		if head==null:head=c.model.get_node_or_null(^"Anchors/Head")
		_camera=c.viewer.get_node_or_null(^"../../") as TpsCamera
		if _camera!=null:_head=_camera.head
		if _head==null:_camera=null

func _on_enter()->void:
	#
	var c:TpsController=get_character()
	lock=c.lock
	if _camera!=null:_camera.head=head
	#
	super._on_enter()

func _on_exit()->void:
	if _camera!=null:_camera.head=_head
	#
	super._on_exit()
