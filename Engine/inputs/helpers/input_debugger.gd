class_name InputDebugger extends Node

static var s_button_keys:Array[StringName]=[&"off",&"on",&"tap",&"hold",&"trigger"]
static var s_button_tags:Array[StringName]=[&"Off",&"On",&"Tap",&"Hold",&"Trigger"]

@export var keyboard:KeyboardInput
@export var pointer:PointerInput
@export var input:PlayerInput
@export var axes:Array[StringName]
@export var buttons:Array[StringName]
@export var label:Label

func better(a:Array[StringName],b:Array[StringName],i:int)->StringName:
	if i<a.size():return a[i]
	if i<b.size():return b[i]
	return LangExtension.s_none_string

func get_axis(i:int)->StringName:
	return better(axes,input.axes,i)

func get_button(i:int)->StringName:
	return better(buttons,input.buttons,i)

func to_text()->String:
	var tab="    "
	var tmp=name;
	if keyboard!=null:
		tmp+="\nKeyboard:\n"
		tmp+=tab+keyboard.to_string()
	if pointer!=null:
		tmp+="\nPointer:"
		var m:PointerInput.PointerEvent=pointer.get_mouse()
		#if m.twice():print("PointerInput.get_mouse().twice()")
		tmp+=tab+"\nMouse:{0},{1},{2},{3}".format(["%0.2f"%m.position.x,"%0.2f"%m.position.y,"%0.2f"%m.pressure,LangExtension.mask_to_str(m.buttons,PointerInput.k_buttons)])
		var a:Array[PointerInput.PointerEvent];pointer.get_touches(a);var n:int=0
		for it in a:
			tmp+=tab+"\nTouch#{0}:{1},{2},{3}".format(["%02d"%it.index,"%0.2f"%it.position.x,"%0.2f"%it.position.y,"%0.2f"%it.pressure])
			n+=1
		for i in pointer.capacity-n:
			tmp+="\n"
	if input!=null:
		tmp+="\nAxes:"
		for i in input.axes.size()/2:
			tmp+=tab+"\n{0}/{1}:{2}".format([get_axis(2*i),get_axis(2*i+1),"%0.2f"%input.axis(i)])
		tmp+="\nButtons:"
		for i in input.buttons.size():
			tmp+="\n"
			tmp+=tab+get_button(i)+":"
			tmp+=to_button(i)
	return tmp

func to_button(b:int)->String:
	if input==null:return LangExtension.s_none_string
	#
	var tmp:String;
	var i:int=-1;for it in s_button_tags:
		i+=1;
		if input.call(s_button_keys[i],b):
			if tmp.is_empty():tmp=it
			else:tmp+=";"+it
	return tmp;

func _ready()->void:
	if keyboard==null:keyboard=KeyboardInput.current
	if pointer==null:pointer=PointerInput.current
	if input==null:input=PlayerInput.current

func _process(delta: float)->void:
	if input==null:return
	if label!=null:label.text=to_text()
