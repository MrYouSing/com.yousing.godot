class_name FsmComposite extends FsmState

@export_group("Composite")
@export var lowers:Array[FsmState]
@export var highers:Array[FsmState]
@export var states:Array[FsmState]
@export var blacklist:Array[StringName]

func do_check(l:Array[FsmState])->bool:
	for i in l:
		if i==null:continue
		i.root=root
		for t in i.transitions:
			if t==null or t.next==null or blacklist.has(t.next.name):continue
			if root.check_transition(i,t):return false
	return true

func _on_check()->bool:
	return do_check(highers) and super._on_check() and do_check(lowers)

func _on_enter()->void:for it in states:if it!=null:it.root=root;it._on_enter()
func _on_tick()->void:for it in states:if it!=null:it.root=root;it._on_tick()
func _on_exit()->void:for it in states:if it!=null:it.root=root;it._on_exit()
