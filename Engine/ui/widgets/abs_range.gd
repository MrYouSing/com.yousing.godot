## An abstract fake [Range].
@abstract class_name AbsRange extends Node

@export_group("Range")
@export var min_value:float=0.0
@export var max_value:float=100.0
@export var step:float=0.01
@export var rounded:bool=false
@export var value:float=0.0:set=_set_value
## See [method Range.share]
@export var share:Node
## See [signal Range.value_changed]
signal value_changed(f:float)

func _on_check(f:float)->float:
	f-=min_value;if step>0.0:f=floorf(f/step)*step
	return min_value+clampf(roundf(f) if rounded else f,0.0,max_value-min_value)

func _on_changed(f:float)->void:
	LangExtension.begin_busy(self)
	if share!=null and has_meta(&"share_sync"):share.value=f
	_value_changed(_on_check(f))
	value_changed.emit(f)
	LangExtension.end_busy(self)

func _set_value(f:float)->void:
	if LangExtension.not_busy(self):_on_changed(f)
	value=f

## See [method Range._value_changed]
@abstract func _value_changed(f:float)->void

func set_value(f:float)->void:
	if LangExtension.is_busy(self):return
	value=f

## See [method Range.set_value_no_signal]
func set_value_no_signal(f:float)->void:
	LangExtension.begin_busy(self)
	_value_changed(_on_check(f))
	value=f
	LangExtension.end_busy(self)

func _ready()->void:
	if share!=null:
		if has_meta(&"share_sync"):share.value=value
		else:set_value_no_signal(share.value)
		share.connect(&"value_changed",set_value)
	else:
		value=value

func _exit_tree()->void:
	if share!=null:
		share.disconnect(&"value_changed",set_value)
