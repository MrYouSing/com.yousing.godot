class_name InputTrigger extends BaseTrigger

@export_group("Input")
@export var input:PlayerInput
@export var action:InputTrigger.Action

enum Action {
	On,
	Off,
	Down,
	Up,
	Tap,
	Hold,
	Trigger,
	Any=-1,
}
