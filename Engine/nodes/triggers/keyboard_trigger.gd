class_name KeyboardTrigger extends BaseTrigger

@export var input:KeyboardInput
@export var key:Key
@export var action:InputTrigger.Action

func is_trigger()->bool:
	if input!=null:
		match action:
			InputTrigger.Action.On:return input.on(key)
			InputTrigger.Action.Off:return input.off(key)
			InputTrigger.Action.Down:return input.down(key)
			InputTrigger.Action.Up:return input.up(key)
	elif action==InputTrigger.Action.On:
		return true
	return false
