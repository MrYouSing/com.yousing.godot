class_name InputDebugger extends Node

static var s_button_keys:Array[StringName]=[&"off",&"on",&"tap",&"hold",&"trigger"]
static var s_button_tags:Array[StringName]=[&"Off",&"On",&"Tap",&"Hold",&"Trigger"]

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
	if input==null:return LangExtension.s_none_string
	#
	var tab="    "
	var tmp=name+"\n";var i:int
	tmp+="Axes:\n"
	i=-1;for it in range(input.axes.size()/2):
		i+=1;
		tmp+=tab+"{0}/{1}:{2}\n".format([get_axis(2*i),get_axis(2*i+1),"%0.2f"%input.axis(i)])
	tmp+="Buttons:\n"
	i=-1;for it in input.buttons:
		i+=1;tmp+=tab+get_button(i)+":"
		tmp+=to_button(i)
		tmp+="\n"
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

func _process(delta: float)->void:
	if input==null:return
	if label!=null:label.text=to_text()
