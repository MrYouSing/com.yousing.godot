class_name AnimationExtension

static func get_blend_shape_names(r:MeshInstance3D,a:Array[StringName])->void:
	if r==null:return
	var m:ArrayMesh=r.mesh;if m==null:return
	for i in m.get_blend_shape_count():a.append(m.get_blend_shape_name(i))

static func get_root_node(m:AnimationMixer)->Node:
	if m==null:return null
	return m.get_node_or_null(m.root_node)

static func set_root_node(m:AnimationMixer,a:Node,b:bool=false)->void:
	if m==null:return
	if not b and not m.root_node.is_empty():return
	m.root_node=m.get_path_to(a)

static func get_anim_player(t:AnimationTree)->AnimationPlayer:
	if t==null:return null
	return t.get_node_or_null(t.anim_player)

static func set_anim_player(t:AnimationTree,a:AnimationPlayer,b:bool=false)->void:
	if t==null or a==null:return
	if not b and not t.anim_player.is_empty():return
	t.anim_player=t.get_path_to(a)

static func get_expression_node(t:AnimationTree)->Node:
	if t==null:return null
	return t.get_node_or_null(t.advance_expression_base_node)

static func set_expression_node(t:AnimationTree,a:Node,b:bool=false)->void:
	if t==null or a==null:return
	if not b and not t.advance_expression_base_node.is_empty() and t.advance_expression_base_node!=^".":return
	t.advance_expression_base_node=t.get_path_to(a)

static func find_bones(c:Skeleton3D,k:PackedStringArray,b:PackedInt32Array)->void:
	if c==null:return
	var n:int=k.size();if n==null:return
	if b.size()!=n:b.resize(n)
	for i in n:b[i]=c.find_bone(k[i])

static func get_bone_global_poses(c:Skeleton3D,i:PackedInt32Array,p:Array[Transform3D])->void:
	if c==null:return
	p.clear();for it in i:
		if it>=0:p.append(c.get_bone_global_pose(it))
		else:p.append(Transform3D.IDENTITY)

static func set_bone_global_rotation(c:Skeleton3D,i:int,q:Quaternion)->void:
	if c==null or i<0:return
	var p:Transform3D=c.get_bone_global_pose(i)
	p.basis=Basis(q)
	c.set_bone_global_pose(i,p)

static func get_pole_node(n:Node,i:int=0)->Node:
	if n!=null:
		var p:NodePath=n.get_pole_node(i)
		if p.is_empty():n=null
		else:n=n.get_node_or_null(p)
	return n

static func set_pole_node(n:Node,v:Node,i:int=0)->void:
	if n!=null:
		if v==null:n.set_pole_node(i,LangExtension.k_empty_path)
		else:n.set_pole_node(i,n.get_path_to(v))

static func get_target_node(n:Node,i:int=0)->Node:
	if n!=null:
		var p:NodePath=n.get_target_node(i)
		if p.is_empty():n=null
		else:n=n.get_node_or_null(p)
	return n

static func set_target_node(n:Node,v:Node,i:int=0)->void:
	if n!=null:
		if v==null:n.set_target_node(i,LangExtension.k_empty_path)
		else:n.set_target_node(i,n.get_path_to(v))

static func event_animator(a:Animator,e:BaseMachine)->void:
	if a==null:return
	#
	if e!=null:
		if a.machine==null:a.machine=e
		else:a.machine.add_target(e);a.machine.dirty=true
	else:
		e=a.machine;if e==null:return
		#
		if a.get_parent().is_ancestor_of(e):
			e.targets.clear();e.dirty=true
		else:
			a.machine=null
