class_name CompositeTrigger extends BaseTrigger

@export var all:bool
@export var triggers:Array[BaseTrigger]

func is_trigger()->bool:
	if all:
		var i:int=0
		for it in triggers:
			if it==null:continue
			if it.is_trigger():return false
			else:i+=1
		return i>0
	else:
		for it in triggers:
			if it==null:continue
			if it.is_trigger():return true
	return false

func _on_enter()->void:for it in triggers:if it!=null:it._on_enter()
func _on_tick(d:float)->void:for it in triggers:if it!=null:it._on_tick(d)
func _on_exit()->void:for it in triggers:if it!=null:it._on_exit()
