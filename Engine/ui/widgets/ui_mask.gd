## A view for multiple-selection from options.
class_name UIMask extends UIOption

@export_group("Mask")
@export var radio:bool
@export var separator=&"|"

var _names:PackedStringArray
var _dummies:int

func rebuild()->void:
	var b:bool=_busy;_busy=true
	_dummies=0;super.rebuild()
	if value==null and type>=TYPE_ARRAY:
		value=[]
	_busy=b

func menu(m:PopupMenu,o:Option,i=-1)->void:
	if m!=null and o!=null:
		var k:StringName=o.name
		if k.is_empty():
			_dummies+=1
			m.add_separator(tr(o.tooltip,category))
		else:
			k=tr(k,category)
			if o.icon!=null:
				if radio:m.add_icon_radio_check_item(o.icon,k,i)
				else:m.add_icon_check_item(o.icon,k,i)
			else:
				if radio:m.add_radio_check_item(k,i)
				else:m.add_check_item(k,i)
			m.set_item_metadata(i,o.value)
			if !o.tooltip.is_empty():m.set_item_tooltip(i,tr(o.tooltip,category))

func find(v:Variant)->int:
	var m:int=0;_names.clear()
	if v==null:
		pass
	elif type==TYPE_INT:
		var n:int=v
		var i:int=-1;for it in _options:
			i+=1;if n&it.value!=0:
				m|=(1<<i)
				_names.append(tr(it.name,category))
	elif type>=TYPE_ARRAY:
		var a:Array=v;var i:int
		for it in a:
			i=super.find(it);if i>=0:
				m|=(1<<i)
				_names.append(tr(_options[i].name,category))
	return m

func _index_selected(i:int)->Variant:
	var b:bool=!pressed(i)
	if type==TYPE_INT:
		var m:int=0
		for j in _options.size():
			if i==j:
				if b:m|=_options[j].value
			elif pressed(j):
				m|=_options[j].value
		return m
	elif type>=TYPE_ARRAY:
		var a:Array=value;a.clear()
		for j in _options.size():
			if i==j:
				if b:a.append(_options[j].value)
			elif pressed(j):
				a.append(_options[j].value)
		return a
	return null

func _value_changed(v:Variant)->void:
	if container==null:return
	var p:int=find(v);var n:int=_options.size()
	if _popup!=null:
		for i in n:_popup.set_item_checked(i,p&(1<<i)!=0)
		_popup.id_pressed.emit(-1)
	else:
		for i in n:_views[i].set_pressed_no_signal(p&(1<<i)!=0)
	#
	var s:String;var a:int=_names.size()
	if a==0:s=tr(&"Nothing",category)
	elif a==n-_dummies:s=tr(&"Everything",category)
	else:s=separator.join(_names)
	container.set(&"text",s)
