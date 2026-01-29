## A view for single-selection from options.
class_name UIEnum extends UIOption

func _index_selected(i:int)->Variant:
	return _options[i].value

func _value_changed(v:Variant)->void:
	if container==null:return
	var p:int=find(v)
	if _popup!=null:
		if !_busy:_popup.id_pressed.emit(p)
	else:
		for i in _options.size():_views[i].set_pressed_no_signal(i==p)
