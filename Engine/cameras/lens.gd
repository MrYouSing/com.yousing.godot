# A preset for cameras and projectors
class_name Lens extends Resource

@export var ortho:bool
@export var mask:int
@export var size:float
@export var aspect:float
@export var near:float
@export var far:float
# For other systems.
@export var settings:Dictionary

func better(a:float,b:float)->float:
	if a>0.0:return a
	else:return b

func direct_to_camera_3d(c:Camera3D)->void:
	if c==null:return
	#
	if ortho:c.set_orthogonal(better(size,c.size),better(near,c.near),better(far,c.far))
	else:c.set_perspective(better(size,c.fov),better(near,c.near),better(far,c.far))
	if mask!=0:c.cull_mask=mask;
	#c.keep_aspect=Camera3D.KEEP_HEIGHT

func tween_to_camera_3d(c:Camera3D,p:Tween,t:Transition)->void:
	if c==null:return
	if p==null or t==null:direct_to_camera_3d(c)
	var b:bool=c.projection==Camera3D.PROJECTION_ORTHOGONAL
	if ortho!=b:printerr("Different projections!");return
	#
	if mask!=0:c.cull_mask=mask;
	#c.keep_aspect=Camera3D.KEEP_HEIGHT
	if near>0.0:t.to_tween(p,c,^"near",near);
	if far>0.0:t.to_tween(p,c,^"far",far);
	if size>0.0:
		if ortho:t.to_tween(p,c,^"size",size);
		else:t.to_tween(p,c,^"fov",size);
