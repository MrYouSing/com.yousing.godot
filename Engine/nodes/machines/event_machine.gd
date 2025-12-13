## An EventDispatcher for machines.
class_name EventMachine extends BaseMachine

@export_group("Event")
@export var events:Dictionary

func _ready()->void:
	for it in get_children():
		if it is Event:events[it.name]=it.event

signal on_event(c:Object,e:StringName)

func find_event(e:StringName,b:bool)->Signal:
	var s:Signal=events.get(e,LangExtension.k_empty_signal)
	if s.is_null() and b:
		if !has_user_signal(e):add_user_signal(e)
		s=Signal(self,e);events[e]=s
	return s

func add_listener(e:StringName,l:Callable,f:int=0)->void:
	if l.is_null():return
	var s:Signal=find_event(e,true)
	if !s.is_connected(l):s.connect(l,f)

func remove_listener(e:StringName,l:Callable)->void:
	var s:Signal=find_event(e,false)
	if !s.is_null():
		if l.is_null():LangExtension.clear_signal(s)
		elif s.is_connected(l):s.disconnect(l)

func invoke_event(e:StringName):
	_on_event(self,e)

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_event,targets,&"_on_event")
	dirty=false

func _on_event(c:Object,e:StringName)->void:
	if dirty:_on_dirty()
	#
	var s:Signal=find_event(e,false)
	if !s.is_null():s.emit()
	on_execute.emit(c,e)

# For other systems.

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	_on_event(c,k)
