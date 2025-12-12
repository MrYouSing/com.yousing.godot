# An input class for 1st person and 3rd person.
class_name XpsInput extends PlayerInput

@export var look:int=1
@export var triggers:Array[BaseTrigger]

func do_update()->void:
	super.do_update()
	if look>=0:
		var v:Vector2=Input.get_last_mouse_velocity()*mouse_to_stick
		if !v.is_zero_approx():m_axes[look]=v

func trigger(i:int)->bool:
	if i>=triggers.size():return super.trigger(i)
	return triggers[i].is_trigger()
