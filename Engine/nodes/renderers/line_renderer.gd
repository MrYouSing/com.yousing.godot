## The Godot version of [url=https://docs.unity3d.com/ScriptReference/LineRenderer.html]LineRenderer[/url].
class_name LineRenderer extends CurveRenderer

@export_group("Line")
@export var line:Line2D
@export var camera:Camera3D
@export_group("Debug")
@export var debug:bool
@export var controls:Array[Node]

var index:int=-1

func set_enabled(b:bool)->void:
	if line!=null:line.visible=b
	if not b:clear()
	set_process(b)

func get_control(i:int,b:bool)->Node:
	var n:int=controls.size()
	var c:Node=null
	if i<n:
		c=controls[i]
		GodotExtension.set_enabled(c,true)
	elif b:
		c=MeshInstance3D.new()
		if n>0:
			c.mesh=controls[0].mesh
		else:
			var s:SphereMesh=SphereMesh.new()
			s.radius=0.05;s.height=0.1
			c.mesh=s
		#
		GodotExtension.add_node(c,null,false)
		controls.append(c)
	return c

func clear()->void:
	if line!=null:line.clear_points()
	for it in controls:GodotExtension.set_enabled(it,false)

func draw()->void:
	if line==null:return
	# Resize
	var i:int=count()
	if line.get_point_count()!=i:
		clear();while i>0:i-=1;line.add_point(Vector2.ZERO)
	# Draw
	index=0
	if root==null:pass
	elif root is Node3D:if camera!=null:_on_3d()
	else:_on_2d()
	index=-1

func _begin_2d(v:Vector2)->void:
	if index>=0:line.set_point_position(index,v);index+=1

func _draw_2d(a:Vector2,b:Vector2)->void:
	if index>=0:
		line.set_point_position(index,b);index+=1

func _end_2d(v:Vector2)->void:
	if index>=0:pass

func _flush_2d(v:Vector2)->void:
	if index>=0:
		var n:int=count()-index
		for i in n:line.set_point_position(index+i,v)
		index=-1

func _begin_3d(v:Vector3)->void:
	if debug:GodotExtension.set_global_position(get_control(index,true),v)
	_begin_2d(camera.unproject_position(v))

func _draw_3d(a:Vector3,b:Vector3)->void:
	if debug:GodotExtension.set_global_position(get_control(index,true),b)
	_draw_2d(camera.unproject_position(a),camera.unproject_position(b))

func _end_3d(v:Vector3)->void:
	_end_2d(camera.unproject_position(v))

func _flush_3d(v:Vector3)->void:
	if debug:
		var n:int=controls.size()-index
		for i in n:GodotExtension.set_enabled(get_control(index+i,false),false)
	_flush_2d(camera.unproject_position(v))

func _ready()->void:
	if line==null:line=GodotExtension.assign_node(self,"Line2D")
	super._ready()
