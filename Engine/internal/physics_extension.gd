class_name PhysicsExtension

class HitInfo:
	var collider:Object
	var rid:RID
	var point:Vector3
	var normal:Vector3

	static func from_dict(d:Dictionary)->HitInfo:
		var tmp:HitInfo=HitInfo.new()
		tmp.collider=d.collider
		tmp.rid=d.rid
		tmp.point=d.position
		tmp.normal=d.normal
		return tmp

	static func from_points(c:Object,a:Vector3,b:Vector3)->HitInfo:
		var tmp:HitInfo=HitInfo.new()
		tmp.collider=c;if c.has_method(&"get_rid"):tmp.rid=c.get_rid()
		tmp.point=a;tmp.normal=(b-a).normalized()
		return tmp

	static func from_ray(n:Node)->HitInfo:
		if n==null:return null
		#if not n.is_colliding():return null
		#
		var tmp:HitInfo=HitInfo.new()
		tmp.rid=n.get_collider_rid()
		tmp.collider=n.get_collider()
		#tmp.shape=n.get_collider_shape()
		tmp.point=n.get_collision_point()
		tmp.normal=n.get_collision_normal()
		return tmp

	static func from_cast(n:Node,i:int)->HitInfo:
		if n==null:return null
		#if i>n.get_collision_count():return null
		#
		var tmp:HitInfo=HitInfo.new()
		tmp.rid=n.get_collider_rid(i)
		tmp.collider=n.get_collider(i)
		#tmp.shape=n.get_collider_shape(i)
		tmp.point=n.get_collision_point(i)
		tmp.normal=n.get_collision_normal(i)
		return tmp

static var s_gravity:Vector3=Vector3(0.0,-9.8,0.0)

static func set_enabled(n:Node,b:bool)->void:
	if n!=null:
		n.set(&"visible",b)
		if b:n.process_mode=Node.PROCESS_MODE_INHERIT
		else:n.process_mode=Node.PROCESS_MODE_DISABLED

# Physics APIs

static var shared_max:int=32
static var shared_rids:Array[RID]
static var shared_ray:=PhysicsRayQueryParameters3D.new()
static var shared_shape:=PhysicsShapeQueryParameters3D.new()
static var shared_sphere:=SphereShape3D.new()
static var shared_box:=BoxShape3D.new()
static var shared_capsule:=CapsuleShape3D.new()

static func ray_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_ray.from=a;shared_ray.to=b
	shared_ray.collision_mask=m;shared_ray.exclude=e
	# Flags
	shared_ray.collide_with_areas  =(f&0x01)!=0
	shared_ray.collide_with_bodies =(f&0x02)!=0
	shared_ray.hit_back_faces      =(f&0x04)!=0
	shared_ray.hit_from_inside     =(f&0x08)!=0
	return c.intersect_ray(shared_ray)

static func shape_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,q:Basis,s:Shape3D,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_shape.transform=Transform3D(q,a)
	shared_shape.motion=b-a
	shared_shape.collision_mask=m;shared_shape.exclude=e
	# Flags
	shared_shape.collide_with_areas  =(f&0x01)!=0
	shared_shape.collide_with_bodies =(f&0x02)!=0
	#
	shared_shape.shape=s;shared_shape.margin=0.0
	var tmp:PackedFloat32Array=c.cast_motion(shared_shape)
	var map:Dictionary={}
	if tmp[0]!=1.0 or tmp[1]!=1.0:# No collision [1.0, 1.0].
		map.position=a.lerp(b,tmp[0])
		map.normal=(a-b).normalized()
	return map

static func sphere_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,r:float,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_sphere.radius=r
	return shape_cast(c,a,b,Basis.IDENTITY,shared_sphere,m,e,f)

static func box_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,q:Basis,s:Vector3,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_box.size=s
	return shape_cast(c,a,b,q,shared_box,m,e,f)

static func capsule_cast(c:PhysicsDirectSpaceState3D,a:Vector3,b:Vector3,q:Basis,r:float,h:float,m:int,e:Array[RID],f:int=-1)->Dictionary:
	shared_capsule.radius=r;shared_capsule.height=h
	return shape_cast(c,a,b,q,shared_capsule,m,e,f)

static func shape_overlap(c:PhysicsDirectSpaceState3D,p:Vector3,q:Basis,s:Shape3D,m:int,e:Array[RID],f:int=-1)->Array:
	shared_shape.transform=Transform3D(q,p)
	shared_shape.motion=Vector3.ZERO
	shared_shape.collision_mask=m;shared_shape.exclude=e
	# Flags
	shared_shape.collide_with_areas  =(f&0x01)!=0
	shared_shape.collide_with_bodies =(f&0x02)!=0
	#
	shared_shape.shape=s;shared_shape.margin=0.0
	var tmp:Array[Dictionary]=c.intersect_shape(shared_shape,shared_max)
	if not tmp.is_empty():return tmp
	return LangExtension.k_empty_array

static func sphere_overlap(c:PhysicsDirectSpaceState3D,p:Vector3,r:float,m:int,e:Array[RID],f:int=-1)->Array:
	shared_sphere.radius=r
	return shape_overlap(c,p,Basis.IDENTITY,shared_sphere,m,e,f)

static func box_overlap(c:PhysicsDirectSpaceState3D,p:Vector3,q:Basis,s:Vector3,m:int,e:Array[RID],f:int=-1)->Array:
	shared_box.size=s
	return shape_overlap(c,p,q,shared_box,m,e,f)

static func capsule_overlap(c:PhysicsDirectSpaceState3D,p:Vector3,q:Basis,r:float,h:float,m:int,e:Array[RID],f:int=-1)->Array:
	shared_capsule.radius=r;shared_capsule.height=h
	return shape_overlap(c,p,q,shared_capsule,m,e,f)

# Area APIs

static func begin_area(n:Node)->void:
	if n!=null and n.get_class()!="Node":
		var p:Node=n.get_parent()
		while p!=null:
			if p.is_class("CollisionObject3D"):
				GodotExtension.add_node(n,null,true);return
			p=p.get_parent()

static func end_area(n:Node,p:Node,v:Variant)->void:
	if p==null:return
	if n!=null and n.get_class()!="Node":
		var q:Node=n.get_parent()
		if q==null or (p!=q and not p.is_ancestor_of(q)):
			GodotExtension.add_node(n,p,false)
			if v!=null:n.set(&"transform",v)

# Cast APIs

static func is_ray(n:Node)->bool:
	if n!=null:
		if n.is_class("RayCast3D"):return true
		if n.is_class("RayCast2D"):return true
	return false

static func is_cast(n:Node)->bool:
	if n!=null:
		if n.is_class("ShapeCast3D"):return true
		if n.is_class("ShapeCast2D"):return true
	return false

static func info_ray(n:Node,d:Dictionary)->bool:
	if n==null:return false
	#if not n.is_colliding():return false
	#
	d.rid=n.get_collider_rid()
	d.collider=n.get_collider()
	#d.shape=n.get_collider_shape()
	d.point=n.get_collision_point()
	d.normal=n.get_collision_normal()
	return true

static func info_cast(n:Node,i:int,d:Dictionary)->bool:
	if n==null:return false
	#if i>n.get_collision_count():return false
	#
	d.rid=n.get_collider_rid(i)
	d.collider=n.get_collider(i)
	#d.shape=n.get_collider_shape(i)
	d.point=n.get_collision_point(i)
	d.normal=n.get_collision_normal(i)
	return true
