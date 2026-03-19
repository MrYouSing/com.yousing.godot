class_name FsmRoot extends FsmNode

@export_group("Root")
@export var context:Node
@export var input:PlayerInput
@export var states:Array[FsmState]

var state:FsmState
var other:FsmState
var time:Vector2

signal on_change(a:FsmState,b:FsmState)

func _ready()->void:
	#
	if input!=null:init_input()
	if states.is_empty():init_root()
	#
	for it in states:
		if it!=null:it.root=self;it._on_init()
	set_state(states[0])

func _process(delta:float)->void:
	time.x+=delta;time.y=delta;
	if state!=null&&state._on_check():
		state._on_tick()

func init_input()->void:
	var kb:KeyboardInput=input.get_node_or_null(^"./Keyboard")
	for it in self.get_node(^"./Triggers").get_children():
		if it is InputTrigger and it.input==null:it.input=input
		elif it is KeyboardTrigger and it.input==null:it.input=kb

func init_root()->void:
	for it in self.get_node(^"./States").get_children():
		if it is FsmNode:states.append(it)

func get_prev()->FsmState:
	if other!=null and time.x<0.0:return other
	return state

func get_next()->FsmState:
	if other!=null and time.x>=0.0:return other
	return state

func get_state(k:StringName)->FsmState:
	if states.is_empty():init_root()
	for it in states:
		if it!=null and it.name==k:return it
	return null

func set_state(v:FsmState,e:bool=true)->void:
	#
	if e and on_change.has_connections():
		var o:FsmState=state
		on_change.emit(o,v)
		if state!=o:return
	#
	other=v
	if state!=null:state._on_exit()
	other=state;time.x=-MathExtension.k_epsilon;state=v
	if state!=null:state._on_enter()
	time.x=0.0;other=null

func check_transition(s:FsmState,t:FsmTransition)->bool:
	if s!=null and t!=null:
		t.state=s
		if t.in_time(time.x) and t.is_trigger():
			set_state(t.next)
			return false
	return true

func check_transitions(s:FsmState,t:Array[FsmTransition])->bool:
	if s!=null and t!=null:
		for it in t:
			it.state=s
			if it.in_time(time.x) and it.is_trigger():
				set_state(it.next)
				return false
		return true
	return false
