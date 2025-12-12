class_name InputTrigger extends BaseTrigger

@export var input:PlayerInput
@export var button:int
@export var action:InputTrigger.Action

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
	elif action==InputTrigger.Action.On:
		return true
	return false

enum Action {
	On,
	Off,
	Down,
	Up,
	Tap,
	Hold,
	Trigger,
}
