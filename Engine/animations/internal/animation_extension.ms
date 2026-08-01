/* <!-- Macro.Define Shortcut
static func get_{2}(n:{0})->{1}:
	if n==null:return null
	return n.get_node_or_null(n.{2})

static func set_{2}(n:{0},v:{1},b:bool=false)->void:
	if n==null:return
	if not b and not n.{2}.is_empty():return
	if v==null:n.{2}=LangExtension.k_empty_path
	else:n.{2}=n.get_path_to(v)

 Macro.End --> */
/* <!-- Macro.Call Shortcut
Node,Node,skeleton,
AnimationMixer,Node,root_node,
AnimationTree,AnimationPlayer,anim_player,
AnimationTree,Node,advance_expression_base_node,
 Macro.End --> */
/* <!-- Macro.Replace
advance_expression_base_node(n:,expression_node(n:
not n.advance_expression_base_node.is_empty():return,not n.advance_expression_base_node.is_empty() and n.advance_expression_base_node!=^".":return
 Macro.End --> */

/* <!-- Macro.Patch
animation_extension.gd,AutoGen
 Macro.End --> */