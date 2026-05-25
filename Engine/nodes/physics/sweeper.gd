## A helper class for [Area3D].[br]
## Bullet Penetration.[br]
## [url=https://github.com/godot-jolt/godot-jolt#whats-not-supported]Jolt Legacy[/url].[br]
## [url=https://github.com/godotengine/godot/issues/74300#issuecomment-4274131605]Godot Issue[/url].
class_name Sweeper extends Tickable

@export_group("Physics")
@export var area:Node
@export var shape:Node
@export var threshold:Vector2=Vector2(0.1,1.0)## x:Move,y:Scale.
@export_flags(
	"Receive Area","Receive Body","Detect Area","Detect Body","Physics Thread",
)var features:int=0x1F

var point:Vector3=MathExtension.k_vec3_nan
var exclude:Array[RID]
var collisions:Array[Object]

func set_update(b:bool)->void:
	if features&0x10!=0:set_process(false);set_physics_process(b)
	else:set_physics_process(false);set_process(b)

func _play()->void:
	collisions.clear();point=MathExtension.k_vec3_nan
	set_update(true)

func _stop()->void:
	collisions.clear();point=MathExtension.k_vec3_nan
	set_update(false)

func _tick()->void:
	if area==null or shape==null:return
	#
	var s:bool=true
	var p:Vector3=GodotExtension.get_global_position(shape)
	if is_nan(point.x):s=true
	else:s=(point-p).length_squared()<=threshold.x*threshold.x
	#
	if area is Node3D:_on_3d(area.get_world_3d().direct_space_state,point,p,s)
	else:_on_2d(area.get_world_2d().direct_space_state,s)
	point=p

func _on_2d(p:PhysicsDirectSpaceState2D,s:bool)->void:
	pass

func _on_3d(p:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,s:bool)->void:
	var f:int=(features>>2)&0x03
	if s:
		var r:Array=PhysicsExtension.shape_overlap(p,b,shape.global_basis,shape.shape,area.collision_mask,exclude,f)
		var c:Object;for it in r:c=it.collider;if not collisions.has(c):_on_find(c)
	else:
		var r:Dictionary=PhysicsExtension.shape_cast(p,a,b,shape.global_basis,shape.shape,area.collision_mask,exclude,f)
		if not r.is_empty():
			var n:int=collisions.size();var v:Vector3=shape.scale
			shape.scale=v*threshold.y;_on_3d(p,a,r.position,true)
			shape.scale=v;if collisions.size()==n:_on_find(area)# Fallback

func _on_find(o:Object)->void:
	if o==null:pass
	elif o.get_class().begins_with("Area"):area.area_entered.emit(o)
	else:area.body_entered.emit(o)

func _on_miss(o:Object)->void:
	if o==null:pass
	elif o.get_class().begins_with("Area"):area.area_exited.emit(o)
	else:area.body_exited.emit(o)

func _on_enter(o:Object)->void:
	if not collisions.has(o):collisions.append(o)

func _on_exit(o:Object)->void:
	collisions.erase(o)

func _ready()->void:
	super._ready()
	#
	if area==null:area=GodotExtension.assign_node(self,"Area3D")
	if shape==null:shape=area.get_node_or_null(^"Shape")
	#
	if features&0x10!=0:set_process(false)
	else:set_physics_process(false)
	if area!=null:
		if features&0x01!=0:
			area.area_entered.connect(_on_enter)
			area.area_exited.connect(_on_exit)
		if features&0x02!=0:
			area.body_entered.connect(_on_enter)
			area.body_exited.connect(_on_exit)

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	#
	if area!=null:
		if features&0x01!=0:
			area.area_entered.disconnect(_on_enter)
			area.area_exited.disconnect(_on_exit)
		if features&0x02!=0:
			area.body_entered.disconnect(_on_enter)
			area.body_exited.disconnect(_on_exit)

func _physics_process(d:float)->void:
	_process(d)
