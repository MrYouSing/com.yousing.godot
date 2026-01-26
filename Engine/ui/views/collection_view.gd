## A base view that shows a collection of models.
class_name CollectionView extends Node

@export_group("Collection")
@export var capacity:int
@export var index:Vector2i## x for Select,y for Render.
@export var model:Resource
@export var database:UIDatabase
@export var models:Array[Resource]
@export_group("Nodes")
@export var container:Node
@export var prefab:Node
@export var arrow:Node
@export_group("Input")
@export var rate:int
@export var inputs:int=7
@export var buttons:Array[StringName]=[&"ui_left",&"ui_right",&"ui_up",&"ui_down",&"ui_accept",&"ui_cancel",&"ui_select"]
@export var triggers:Array[BaseTrigger]

signal on_focus()
signal on_blur()

var _start:int=-1
var _model:Resource
var _view:Node
var _views:Array[Node]

func get_loop(i:int,n:int,m:LoopMode,b:int=-1)->bool:
	match m&0xFF:
		LoopMode.Loop:return true
		LoopMode.Repeat:
			if i<0 or i>=n:if b>=0 and b<triggers.size():
				var it:BaseTrigger=triggers[b]
				if it!=null:
					var c:Variant=it.get(&"_count")
					if c!=null:return c<=1# Only first.
			return true
		_:return false

func wrap_index(i:int,n:int,l:bool)->int:
	if l:return wrapi(i,0,n)
	else:return clampi(i,0,n-1)

func move_index(i:int,a:int,z:int)->int:
	if i<a:return i
	elif i>z:return a+(i-z)
	return a

# Override it for better performance.
func is_input(i:int)->bool:
	if i>=0 and i<inputs:
		if i<triggers.size():
			var it:BaseTrigger=triggers[i]
			if it!=null:return it.is_trigger()
		if i<buttons.size():
			var it:StringName=buttons[i]
			if !it.is_empty():return Input.is_action_just_pressed(it)
		if UIManager.exists:
			return UIManager.instance.is_tap(i)
	return false

func num_models()->int:
	if database!=null:return database.models.size()
	else:return models.size()

func get_model(i:int)->Resource:
	if database!=null:return database.models[i]
	else:return models[i]

func find_model(k:StringName)->Resource:
	if database!=null:return database.find(k)
	else:for it in models:if it!=null and it.resource_name==k:return it
	return null

func new_view()->Node:
	var v:Node=prefab.duplicate()
	if v is Control:# Managed focus.
		v.focus_mode=Control.FOCUS_NONE
		v.connect(&"button_down",focus.bind(_views.size()))
	container.add_child(v)
	return v

func get_view(i:int)->Node:
	var v:Node
	if i<_views.size():v=_views[i]
	else:v=new_view();_views.append(v)
	return v

func set_view(v:Node,m:Resource)->void:
	if v==null:return
	if m==null:m=model
	v.set(&"model",m)

func draw_view(i:int,j:int)->void:
	var m:Resource=null;if j>=0:m=get_model(j)
	set_view(get_view(i),m)

func focus(i:int)->void:
	if i>=0:
		_view=_views[i];_model=_view.get(&"model")
		if arrow!=null:
			GodotExtension.add_node(arrow,_view,false)
			GodotExtension.set_enabled(arrow,true)
			#GodotExtension.refresh_node(arrow)
		on_focus.emit()
	else:
		_view=null;_model=null
		if arrow!=null:
			GodotExtension.add_node(arrow,self,false)
			GodotExtension.set_enabled(arrow,false)
		on_blur.emit()

func clear()->void:
	for it in _views:set_view(it,null)

func render()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func listen()->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func execute(i:int)->void:
	LangExtension.throw_exception(self,LangExtension.e_not_implemented)

func _ready()->void:
	if container==null:container=self
	render()

func _process(d:float)->void:
	if rate<0:
		pass
	elif rate==0 or Application.get_frames()%rate==0:
		listen()

enum LoopMode {
	None,
	Loop,
	Repeat,
	SeqNone=0x0100,
	SeqLoop=0x0101,
	SeqRepeat=0x0102,
}
