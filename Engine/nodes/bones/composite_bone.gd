## A helper class for [SkeletonModifier3D] management.
@tool
class_name CompositeBone extends Node

@export_group("Modifier")
@export var active:bool=true:
	set(x):
		active=x
		var i:int=-1;for it in bones:
			i+=1;if (mask&(1<<i))==0:continue
			if it==null:continue
			#
			it.active=x
@export_range(0.0,1.0,0.001)var influence:float=1.0:
	set(x):
		influence=x;
		var s:float=scale;var f:float
		var i:int=-1;for it in bones:
			i+=1;if (mask&(1<<i))==0:continue
			if it==null:continue
			#
			f=s*x
			if it is BaseBone:it._on_blend(self,f)
			else:it.influence=f;active=!is_zero_approx(f)
@export_group("Composite")
@export_flags_3d_physics var mask:int=-1
@export var scale:float=1.0:
	set(x):scale=x;influence=influence
@export var bones:Array[Node]

func set_enabled(b:bool)->void:active=b
func show()->void:active=true
func hide()->void:active=false

# For other systems.

func _on_toggle(c:Object,b:bool)->void:
	active=b

func _on_blend(c:Object,f:float)->void:
	influence=f
