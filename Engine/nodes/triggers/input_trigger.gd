class_name InputTrigger extends BaseTrigger
@export var input:PlayerInput
@export var button:int
@export var action:InputTrigger_Action

func is_trigger()->bool:
	if input!=null:
		match action:
			InputTrigger_Action.On:return input.on(button)
			InputTrigger_Action.Off:return input.off(button)
			InputTrigger_Action.Down:return input.down(button)
			InputTrigger_Action.Up:return input.up(button)
			InputTrigger_Action.Tap:return input.tap(button)
			InputTrigger_Action.Hold:return input.hold(button)
			InputTrigger_Action.Trigger:return input.trigger(button)
	elif action==InputTrigger_Action.On:
		return true
	return false

enum InputTrigger_Action {
	On,
	Off,
	Down,
	Up,
	Tap,
	Hold,
	Trigger,
}
