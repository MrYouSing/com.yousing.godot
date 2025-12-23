class_name TransitionLibrary extends Resource

@export var transitions:Array[Transition]

func find(from:StringName,to:StringName)->Transition:
	for it in transitions:
		if it!=null and it.from==from and it.to==to:return it
	return null

func eval(from:StringName,to:StringName)->Transition:
	var tmp:Transition=find(from,to)
	if tmp!=null:return tmp
	tmp=find(&"*",to)
	if tmp!=null:return tmp
	tmp=find(from,&"*")
	if tmp!=null:return tmp
	return transitions[0]
