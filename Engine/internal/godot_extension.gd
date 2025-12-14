class_name GodotExtension

# Engine APIs

static var s_engine_frames:int=-1
static var s_engine_time:float=-1.0
static var s_benchmark_names:Array[String]
static var s_benchmark_times:Array[float]

static func get_frames()->int:
	if s_engine_frames>=0:return s_engine_frames
	return Engine.get_process_frames()

static func get_time()->float:
	if s_engine_time>=0.0:return s_engine_time
	return Time.get_ticks_msec()*0.001

static func begin_benchmark(c:String)->void:
	s_benchmark_names.push_back(c)
	s_benchmark_times.push_back(get_time())

static func end_benchmark()->void:
	var c:String=s_benchmark_names.pop_back()
	var t:float=s_benchmark_times.pop_back()
	var d:float=get_time()
	print(c.format([t,d-t,d]))

# Scene APIs

static var s_root:Node
static var s_dimension:int=3

static func destroy(o:Object)->void:
	if o==null:return
	if o is Node:o.queue_free()
	else:o.free()

static func set_enabled(o:Object,b:bool)->void:
	if o==null:return
	if o.has_method(&"set_enabled"):o.set_enabled(b);return
	# Default
	if o is Node:o.set_process(b);o.set_physics_process(b)
	if o is Node3D:o.visible=b
	elif o is Node2D:o.visible=b

static func add_node(n:Node,p:Node=null,b:bool=true)->void:
	if n==null:return
	if p==null:p=s_root
	#
	if n.get_parent()!=null:
		n.reparent(p,b);return
	elif b and (n is Node3D or n is Node2D):
		var t=n.global_transform
		p.add_child(n)
		n.global_transform=t
	else:
		p.add_child(n)

# Animation APIs

static func set_anim_player(t:AnimationTree,a:AnimationPlayer,b:bool=false)->void:
	if t==null or a==null:return
	if !b and !t.anim_player.is_empty():return
	t.anim_player=t.get_path_to(a)

static func set_expression_node(t:AnimationTree,a:Node,b:bool=false)->void:
	if t==null or a==null:return
	if !b and !t.advance_expression_base_node.is_empty() and t.advance_expression_base_node!=^".":return
	t.advance_expression_base_node=t.get_path_to(a)

static func get_bone_global_poses(c:Skeleton3D,i:Array[int],p:Array[Transform3D])->void:
	if c==null:return
	p.clear();for it in i:
		if it>=0:p.append(c.get_bone_global_pose(it))
		else:p.append(Transform3D.IDENTITY)

static func set_bone_global_rotation(c:Skeleton3D,i:int,q:Quaternion)->void:
	if c==null or i<0:return
	var p:Transform3D=c.get_bone_global_pose(i)
	p.basis=Basis(q)
	c.set_bone_global_pose(i,p)

# Physics APIs

static var shared_rids:Array[RID]
static var shared_ray:=PhysicsRayQueryParameters3D.new()
static var shared_shape:=PhysicsShapeQueryParameters3D.new()
static var shared_sphere:=SphereShape3D.new()

static func ray_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_ray.from=a;shared_ray.to=b
	shared_ray.collision_mask=m;shared_ray.exclude=e
	# Flags
	shared_ray.collide_with_areas  =(f&0x01)!=0
	shared_ray.collide_with_bodies =(f&0x02)!=0
	shared_ray.hit_back_faces      =(f&0x04)!=0
	shared_ray.hit_from_inside     =(f&0x08)!=0
	return c.intersect_ray(shared_ray)

static func shape_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,s:Shape3D,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_shape.transform=Transform3D(Basis.IDENTITY,a)
	shared_shape.motion=b-a
	shared_shape.collision_mask=m;shared_shape.exclude=e
	# Flags
	shared_shape.collide_with_areas  =(f&0x01)!=0
	shared_shape.collide_with_bodies =(f&0x02)!=0
	#
	shared_shape.shape=s;shared_shape.margin=0.0
	var tmp:PackedFloat32Array=c.cast_motion(shared_shape)
	var map:Dictionary={}
	if tmp[0]!=1.0 and tmp[1]!=0.0:
		map.position=a.lerp(b,tmp[0])
		map.normal=(a-b).normalized()
	return map;

static func sphere_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,r:float,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_sphere.radius=r
	return shape_cast(c,a,b,shared_sphere,m,e,f)
