## A fake [Range] for displaying number texts.
class_name UINumber extends AbsRange

@export_group("Number")
@export var label:Node
@export_enum("Value","Value/Count","Percent") 
var type:int
@export var format:String="%.2f"

func _value_changed(f:float)->void:
	if label==null:return
	var a:float=min_value;
	var c:float=max_value-a
	var s:String;match type:
		0:s=format%f
		1:s="{0}/{1}".format([format%(f-a),format%c])
		1:s=format%((f-a)/c)
	label.text=s
