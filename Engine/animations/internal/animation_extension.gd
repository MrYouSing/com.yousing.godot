class_name AnimationExtension

static func get_blend_shape_names(r:MeshInstance3D,a:Array[StringName])->void:
	if r==null:return
	var m:ArrayMesh=r.mesh;if m==null:return
	for i in m.get_blend_shape_count():a.append(m.get_blend_shape_name(i))

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
