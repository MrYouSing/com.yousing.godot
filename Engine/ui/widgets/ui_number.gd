## A fake [Range] for displaying number texts.
class_name UINumber extends AbsRange

@export_group("Number")
@export var label:Node
@export_enum("Value","Value/Count","Percent","Time","Time/Duration") 
var type:int
@export var format:String="%.2f"

func time(f:float)->String:
	var t:Vector4=MathExtension.float_to_time(f)
	return format.format(["%02d"%t.x,"%02d"%t.y,"%02d"%t.z,"%02d"%(t.w*100.0)])

func _value_changed(f:float)->void:
	if label==null:return
	var a:float=min_value;
	var c:float=max_value-a
	var s:String;match type:
		0:s=format%f
		1:s="{0}/{1}".format([format%(f-a),format%c])
		2:s=format%((f-a)/c*100.0)
		3:s=time(f)
		4:s="{0}/{1}".format([time(f-a),time(c)])
	label.text=s
