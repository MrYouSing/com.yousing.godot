## A helper class that runs in [method Node._process] or [method Node._physics_process].
class_name Updatable extends Runnable

static func make(n:Node,k:StringName)->bool:
	if n!=null:
		match k:
			&"_process":n.set_process(true);n.set_physics_process(false);return true
			&"_physics":n.set_process(false);n.set_physics_process(true);return true
			_:n.set_process(false);n.set_physics_process(false)
	return false


func _ready()->void:
	if make(self,event):return
	super._ready()

func _exit_tree()->void:
	if GodotExtension.s_reparenting:return
	#
	if make(self,event):return
	super._exit_tree()

func _process(d:float)->void:run()
func _physics_process(d:float)->void:run()
