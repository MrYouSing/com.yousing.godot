class_name GodotExtension

# Scene APIs

static var s_root:Node=Engine.get_main_loop().root
static var s_hide:Node
static var s_dimension:int=3
static var s_reparenting:bool

static func destroy(o:Object)->void:
	if o==null:return
	if o is Node:o.queue_free()
	elif o is RefCounted:pass
	else:o.free()

static func create(c:Object,b:Variant,s:Script=null)->Object:
	var o:Object=b.new()
	if s!=null:o.set_script(s)
	if c!=null and c.has_method(&"add_child"):
		c.add_child(o);o.set(&"owner",c)
	return o

static func get_enabled(o:Object)->bool:
	if o==null:return false
	if o.has_method(&"get_enabled"):return o.get_enabled()
	if o is Node:
		var b:Variant=o.get(&"visible")
		return o.is_processing() if b==null else b
	return false

static func set_enabled(o:Object,b:bool)->void:
	if o==null:return
	if o.has_method(&"set_enabled"):o.set_enabled(b);return
	# Default
	if o is Node:
		o.set_process(b);o.set_physics_process(b)
		o.set(&"visible",b)

static func try_enabled(o:Object,i:int)->void:
	if o==null:return
	var b:bool;match i:
		0:b=false
		1:b=true
		-1:b=not get_enabled(o)
	set_enabled(o,b)

  # Node APIs

static func add_node(n:Node,p:Node=null,b:bool=true)->void:
	if n==null:return
	if p==null:p=s_root
	#
	var r:bool=s_reparenting;s_reparenting=true
	if n.get_parent()!=null:
		n.reparent(p,b)
	elif b and (n is Node3D or n is Node2D):
		var t:Variant=n.global_transform
		p.add_child(n)
		n.global_transform=t
	else:
		p.add_child(n)
	s_reparenting=r

static func append_node(n:Node,s:NodePath,p:Node=null,b:bool=true)->void:
	if n==null or s.is_empty():return
	if p==null:p=s_root
	#
	var i:int=s.get_name_count()
	n.name=s.get_name(i-1)
	if i>1:
		var t:NodePath=IOExtension.directory_name(s)
		var q:Node=p.get_node_or_null(t)
		if q==null:
			q=ClassDB.instantiate(p.get_class())
			append_node(q,t,p,false);p=q
	add_node(n,p,b)

static func remove_node(n:Node)->void:
	if n==null:return
	#
	n.reparent(null,false);n.queue_free()

static func move_node(n:Node,i:int)->void:
	if n==null:return
	var p:Node=n.get_parent();if p==null:return
	#
	var c:int=p.get_child_count();i=(i+c)%c
	if n.get_index()!=i:p.move_child(n,i)

static func assign_node(n:Node,s:String)->Node:
	if n!=null:
		if n.is_class(s):return n
		var c:Node=n.get_node_or_null(s)
		if c!=null:return c
		return n.get_parent()
	return null

static func contain_node(a:Array,n:Node)->bool:
	if n!=null:
		for it in a:
			if it==null:continue
			if it==n or it.is_ancestor_of(n):return true
	return false

static func refresh_node(n:Node)->void:
	if n!=null:
		if n.has_method(&"_on_dirty"):n._on_dirty()
		elif n.has_method(&"refresh"):n.refresh()
		else:set_enabled(n,true)

static func input_node(n:Node,i:int)->void:
	if n!=null:
		var j:int
		i>>=0;j=i&0x3;if j!=0:n.set_process_input(j==0x2)
		i>>=2;j=i&0x3;if j!=0:n.set_process_shortcut_input(j==0x2)
		i>>=2;j=i&0x3;if j!=0:n.set_process_unhandled_key_input(j==0x2)
		i>>=2;j=i&0x3;if j!=0:n.set_process_unhandled_input(j==0x2)

  # Transform APIs

static func is_child_of(n:Node,p:Node)->bool:
	if n!=null and p!=null:
		if n==p or p.is_ancestor_of(n):return true
	return false

static func get_global_position(n:Node)->Vector3:
	if n!=null:
		if n is Node3D:return n.global_position
		else:var v:Vector2=n.get(&"global_position");return Vector3(v.x,v.y,0.0)
	return Vector3.ZERO

static func set_global_position(n:Node,p:Vector3)->void:
	if n!=null:
		if n is Node3D:n.global_position=p
		else:n.set(&"global_position",Vector2(p.x,p.y))

static func get_global_basis(n:Node)->Basis:
	if n!=null:
		if n is Node3D:
			return n.global_basis
		else:
			var r:float;var s:Vector2
			if n is Node2D:r=n.global_rotation;s=n.global_scale
			else:r=n.rotation;s=n.scale
			return Basis.from_euler(Vector3.FORWARD,r).scaled_local(Vector3(s.x,s.y,1.0))
	return Basis.IDENTITY

static func set_global_rotation(n:Node,a:float,v:Vector3=Vector3.UP)->void:
	if n!=null:
		if n is Node3D:
			if is_nan(a):n.global_basis=MathExtension.aiming_at(v)
			else:n.global_basis=Basis(v,a*MathExtension.k_deg_to_rad)
		else:
			if is_nan(a):a=MathExtension.clocking_at(Vector2(v.x,v.y))
			else:a*=MathExtension.k_deg_to_rad
			if n is Node2D:n.global_rotation=a
			else:n.set(&"rotation",a)

static func get_global_transform(n:Node)->Transform3D:
	if n!=null:
		if n is Node3D:return n.global_transform
		else:
			var t:Transform2D=n.global_transform if n is Node2D else n.get_global_transform_with_canvas()
			var v:Vector2=t.get_origin();var s:Vector2=t.get_scale()
			return Transform3D(Basis(Vector3.FORWARD,t.get_rotation()),Vector3(v.x,v.y,0.0)).scaled_local(Vector3(s.x,s.y,1.0))
	return Transform3D.IDENTITY

static func set_global_transform(n:Node,t:Transform3D)->void:
	if n!=null:
		if n is Node3D:n.global_transform=t
		else:
			var b:Basis=t.basis;var f:Vector3=Vector3.FORWARD
			var v:Vector3=t.origin;var s:Vector3=b.get_scale()
			n.set(&"global_transform",Transform2D(f.angle_to(b*f),Vector2(s.x,s.y),0.0,Vector2(v.x,v.y)))

static func get_local_transform(n:Node)->Transform3D:
	if n!=null:
		if n is Node3D:return n.transform
		else:
			var t:Transform2D=n.get(&"transform");var v:Vector2=t.get_origin();var s:Vector2=t.get_scale()
			return Transform3D(Basis(Vector3.FORWARD,t.get_rotation()),Vector3(v.x,v.y,0.0)).scaled_local(Vector3(s.x,s.y,0.0))
	return Transform3D.IDENTITY

static func set_local_transform(n:Node,t:Transform3D)->void:
	if n!=null:
		if n is Node3D:n.transform=t
		else:
			var b:Basis=t.basis;var f:Vector3=Vector3.FORWARD
			var v:Vector3=t.origin;var s:Vector3=b.get_scale()
			n.set(&"transform",Transform2D(f.angle_to(b*f),Vector2(s.x,s.y),0.0,Vector2(v.x,v.y)))

# Resource APIs

static func is_prefab(o:Object)->bool:
	if o==null:
		pass
	elif o is Node:
		var n:Node=o.get_parent()
		while n!=null:
			if n.name==&"Hidden":return true
			n=n.get_parent()
	elif o is PackedScene:
		return true
	return false

static func in_stage(o:Object)->bool:
	if o!=null:return not o.get_meta(Stage.k_meta_pool,LangExtension.k_empty_name).is_empty()
	else:return false

static func meta_data(s:Object,k:StringName,d:Object,p:StringName)->void:
	if s!=null and d!=null:
		if s.has_meta(k):d.set(p,s.get_meta(k))

static func meta_node(s:Node,k:StringName,d:Object,p:StringName)->void:
	if s!=null and d!=null:
		if s.has_meta(k):d.set(p,s.get_node_or_null(s.get_meta(k)))

static func scale_shape_3d(s:Shape3D,f:float)->void:
	if s==null:pass
	elif s is SphereShape3D:s.radius*=f
	elif s is CapsuleShape3D:s.radius*=f;s.height*=f
	elif s is BoxShape3D:s.size*=f

static func size_shape_3d(s:Shape3D)->Vector3:
	if s==null:pass
	elif s is SphereShape3D:var f:float=s.radius*2.0;return Vector3(f,f,f)
	elif s is CapsuleShape3D:var f:float=s.radius*2.0;return Vector3(f,s.height,f)
	elif s is BoxShape3D:return s.size
	return Vector3.ZERO

static func resize_shape_3d(s:Shape3D,v:Vector3)->void:
	if s==null:pass
	elif s is SphereShape3D:s.radius=(v.x+v.y+v.z)/6.0
	elif s is CapsuleShape3D:s.radius=(v.x+v.z)*0.25;s.height=v.y
	elif s is BoxShape3D:s.size=v

# Editor APIs

static func editor_dirty(o:Object)->void:
	if o!=null and Engine.is_editor_hint():
		if o is Resource:o.emit_changed()
		else:EditorInterface.mark_scene_as_unsaved()

static func debug_print(k:StringName,s:String)->bool:
	var c:StringName=&"ImGui"
	if not ClassDB.class_exists(c):return false
	ClassDB.class_call_static(c,&"Begin",k)
	ClassDB.class_call_static(c,&"Text",s)
	ClassDB.class_call_static(c,&"End")
	return true
