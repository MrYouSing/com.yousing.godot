class_name FsmRoot extends FsmNode

@export_group("Root")
@export var context:Node
@export var input:PlayerInput
@export var states:Array[FsmState]
var state:FsmState
var time:Vector2

func _ready()->void:
	#
	init_input()
	init_root()
	#
	for it in states:
		if it!=null:it.root=self;it.on_init()
	set_state(states[0])

func _process(delta:float)->void:
	time.x+=delta;time.y=delta;
	if state!=null&&state.on_check():
		state.on_tick()

func init_input()->void:
	if input!=null:
		var kb:KeyboardInput=input.get_node_or_null(^"./Keyboard")
		for it in self.get_node(^"./Triggers").get_children():
			if it is InputTrigger and it.input==null:it.input=input
			elif it is KeyboardTrigger and it.input==null:it.input=kb

func init_root()->void:
	if states.is_empty():
		for it in self.get_node(^"./States").get_children():
			if it is FsmNode:states.append(it)

func get_state(k:String)->FsmState:
	for it in states:
		if it!=null and it.name==k:return it
	return null

func set_state(v:FsmState)->void:
	if v!=null:print(v.name)
	#
	if state!=null:state.on_exit()
	time.x=0.0;state=v;
	if state!=null:state.on_enter()

func check_transitions(s:FsmState,t:Array[FsmTransition])->bool:
	if s!=null and t!=null:
		for it in t:
			it.state=s
			if it.in_time(time.x) and it.is_trigger():
				set_state(it.next)
				return false
		return true
	return false
