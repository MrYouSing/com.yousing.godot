class_name GodotExtension

# Scene APIs

static var s_root:Node=Engine.get_main_loop().root
static var s_hide:Node
static var s_dimension:int=3

static func destroy(o:Object)->void:
	if o==null:return
	if o is Node:o.queue_free()
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
		-1:b=!get_enabled(o)
	set_enabled(o,b)

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

static func get_global_position(n:Node)->Vector3:
	if n!=null:
		if n is Node3D:return n.global_position
		elif n is Node2D:var v:Vector2=n.global_position;return Vector3(v.x,v.y,0.0)
	return Vector3.ZERO

static func set_global_position(n:Node,p:Vector3)->void:
	if n!=null:
		if n is Node3D:n.global_position=p
		elif n is Node2D:n.global_position=Vector2(p.x,p.y)

# Rendering APIs

static func get_blend_shape_names(r:MeshInstance3D,a:Array[StringName])->void:
	if r==null:return
	var m:ArrayMesh=r.mesh;if m==null:return
	for i in m.get_blend_shape_count():a.append(m.get_blend_shape_name(i))

# Animation APIs

static func get_anim_player(t:AnimationTree)->AnimationPlayer:
	if t==null:return null
	return t.get_node_or_null(t.anim_player)

static func set_anim_player(t:AnimationTree,a:AnimationPlayer,b:bool=false)->void:
	if t==null or a==null:return
	if !b and !t.anim_player.is_empty():return
	t.anim_player=t.get_path_to(a)

static func get_expression_node(t:AnimationTree)->Node:
	if t==null:return null
	return t.get_node_or_null(t.advance_expression_base_node)

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
