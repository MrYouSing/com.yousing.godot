class_name ToggleTrigger extends BaseTrigger

@export_group("Toggle")
@export var is_on:bool
@export var trigger:BaseTrigger

func is_trigger()->bool:
	if trigger!=null and trigger.is_trigger():
		is_on=!is_on
	return is_on
