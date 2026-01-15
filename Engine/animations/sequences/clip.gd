## A lightweight [Animation] for custom playables.
class_name Clip extends Resource

@export_group("Clip")
@export var name:StringName
@export var fps:float=60.0:
	set(x):fps=x;step=1.0/x
@export var length:float=1.0
@export var loop:Animation.LoopMode
@export var frames:Array[Frame]

var context:Object
var step:float=1.0/fps

func add_row(h:PackedStringArray,r:PackedStringArray)->void:
	var f=Frame.new()
	LangExtension.row_to_object(h,r,f)
	if f.time>=0.0:length=f.time 
	else:length=step*frames.size()
	frames.append(f)

func get_time(i:int)->float:
	var t:float=frames[i].time
	if t<0.0:t=i*step
	return t

func get_frame(t:float,e:float=0.01)->Frame:
	if t<0.0:
		return frames[roundi(-t)]
	else:
		e*=e;var f:float
		var i:int=-1;for it in frames:
			i+=1;f=it.time;if f<0.0:f=step*i
			f=f-t;if f*f<=e:return it
	return null
