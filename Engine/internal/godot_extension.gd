class_name GodotExtension

# Animation APIs

static func set_anim_player(t:AnimationTree,a:AnimationPlayer,b:bool=false)->void:
	if t==null or a==null:return
	if !b and !t.anim_player.is_empty():return
	t.anim_player=t.get_path_to(a)

static func set_expression_node(t:AnimationTree,a:Node,b:bool=false)->void:
	if t==null or a==null:return
	if !b and !t.advance_expression_base_node.is_empty() and t.advance_expression_base_node!=^".":return
	t.advance_expression_base_node=t.get_path_to(a)
