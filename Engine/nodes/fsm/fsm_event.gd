## An event bridge for other systems.
class_name FsmEvent extends FsmState

static var current:Object

@export_group("Event")
@export var targets:Array[Node]

signal on_init()
signal on_check()
signal on_enter()
signal on_tick()
signal on_exit()

var dirty:bool
var done:bool
var context:Object=self
var events:Array[Signal]=[Signal(),Signal(),Signal(),Signal(),Signal()]

func add_target(t:Node)->void:
	var i:int=targets.find(t);if i>=0:return
	targets.append(t);dirty=true

func remove_target(t:Node)->void:
	var i:int=targets.find(t);if i<0:return
	targets.remove_at(i);dirty=true

func invoke_event(i:int)->bool:
	var tmp:Object=current;current=context
	done=false;events[i].emit()
	current=tmp;return done

func _on_dirty()->void:
	var i:int=0
	events[i]=LangExtension.merge_signal(self,events[i],on_init,targets,&"_on_init");i+=1
	events[i]=LangExtension.merge_signal(self,events[i],on_check,targets,&"_on_check");i+=1
	events[i]=LangExtension.merge_signal(self,events[i],on_enter,targets,&"_on_enter");i+=1
	events[i]=LangExtension.merge_signal(self,events[i],on_tick,targets,&"_on_tick");i+=1
	events[i]=LangExtension.merge_signal(self,events[i],on_exit,targets,&"_on_exit");i+=1
	dirty=false

func _on_init()->void:
	if dirty:_on_dirty()
	invoke_event(0)

func _on_check()->bool:
	if dirty:_on_dirty()
	invoke_event(1);if done:return true
	return super._on_check()

func _on_enter()->void:
	if dirty:_on_dirty()
	invoke_event(2)

func _on_tick()->void:
	if dirty:_on_dirty()
	invoke_event(3)

func _on_exit()->void:
	if dirty:_on_dirty()
	invoke_event(4)
