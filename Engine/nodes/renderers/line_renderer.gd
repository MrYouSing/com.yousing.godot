## The Godot version of [url=https://docs.unity3d.com/ScriptReference/LineRenderer.html]LineRenderer[/url].
class_name LineRenderer extends CurveRenderer

@export_group("Line")
@export var line:Line2D
@export var camera:Camera3D

var index:int=-1

func set_enabled(b:bool)->void:
	if line!=null:line.visible=b
	set_process(b)

func clear()->void:
	if line!=null:line.clear_points()

func draw()->void:
	if line==null:return
	if line.get_point_count()!=count():clear()
	#
	index=0
	if root==null:pass
	elif root is Node3D:if camera!=null:_on_3d()
	else:_on_2d()
	index=-1

func _begin_2d(v:Vector2)->void:
	if index>=0:line.set_point_position(index,v);index+=1

func _draw_2d(a:Vector2,b:Vector2)->void:
	if index>=0:line.set_point_position(index,b);index+=1

func _end_2d(v:Vector2)->void:
	if index>=0:pass

func _begin_3d(v:Vector3)->void:
	_begin_2d(camera.unproject_position(v))

func _draw_3d(a:Vector3,b:Vector3)->void:
	_draw_2d(camera.unproject_position(a),camera.unproject_position(b))

func _end_3d(v:Vector3)->void:
	_end_2d(camera.unproject_position(v))

func _ready()->void:
	if line==null:line=GodotExtension.assign_node(self,"Line2D")
	super._ready()
