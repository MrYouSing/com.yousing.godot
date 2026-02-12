class_name ButtonTrigger extends InputTrigger

@export var button:int

func is_trigger()->bool:
	if input!=null:
		match action:
			InputTrigger.Action.On:return input.on(button)
			InputTrigger.Action.Off:return input.off(button)
			InputTrigger.Action.Down:return input.down(button)
			InputTrigger.Action.Up:return input.up(button)
			InputTrigger.Action.Tap:return input.tap(button)
			InputTrigger.Action.Hold:return input.hold(button)
			InputTrigger.Action.Trigger:return input.trigger(button)
	else:
		match action:
			InputTrigger.Action.Any:return Input.is_anything_pressed()
			InputTrigger.Action.On:return Input.is_action_pressed(name)
			InputTrigger.Action.Off:return not Input.is_action_pressed(name)
			InputTrigger.Action.Down:return Input.is_action_just_pressed(name)
			InputTrigger.Action.Up:return Input.is_action_just_released(name)
	return false
