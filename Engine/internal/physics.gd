class_name Physics

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
	if tmp[0]!=1.0 and tmp[1]!=0.0:
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
	if !tmp.is_empty():return tmp
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
