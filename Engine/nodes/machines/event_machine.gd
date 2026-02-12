## An EventDispatcher for machines.
class_name EventMachine extends BaseMachine

static var current:EventMachine

@export_group("Event")
@export var events:Dictionary[StringName,Signal]

signal on_event(c:Object,e:StringName)

var context:Object

func _ready()->void:
	for it in get_children():
		if it is Event:events[it.name]=it.event

func find_event(e:StringName,b:bool)->Signal:
	var s:Signal=events.get(e,LangExtension.k_empty_signal)
	if s.is_null() and b:
		if not has_user_signal(e):add_user_signal(e)
		s=Signal(self,e);events[e]=s
	return s

func add_listener(e:StringName,l:Callable,f:int=0)->void:
	if l.is_null():return
	var s:Signal=find_event(e,true)
	if not s.is_connected(l):s.connect(l,f)

func remove_listener(e:StringName,l:Callable)->void:
	var s:Signal=find_event(e,false)
	if not s.is_null():
		if l.is_null():LangExtension.clear_signal(s)
		elif s.is_connected(l):s.disconnect(l)

func invoke_event(e:StringName)->void:
	_on_event(self,e)

func emit_event(e:StringName,args:Array)->void:
	if args.is_empty():
		_on_event(self,e)
	else:
		#...var a:Variant=args[0];if typeof(a)>=TYPE_ARRAY:args=a
		LangExtension.s_temp_array.assign(args)
		_on_event(self,e)
		LangExtension.s_temp_array.clear()

func _on_dirty()->void:
	on_execute=LangExtension.merge_signal(self,on_execute,on_event,targets,&"_on_event")
	dirty=false

func _on_event(c:Object,e:StringName)->void:
	if dirty:_on_dirty()
	#
	var tmp:EventMachine=current;current=self;context=c
	on_execute.emit(c,e)# From Engine
	var s:Signal=find_event(e,false);LangExtension.call_signal(s,LangExtension.s_temp_array)# From User
	current=tmp;context=null

# For other systems.

func _on_state(c:Object,k:StringName,v:Variant,t:Transition)->void:
	_on_event(c,k)
