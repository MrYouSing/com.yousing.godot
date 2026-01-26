## An extension class for input system.
class_name InputExtension

static var s_mouse_to_stick:float=0.0005

static func pixel_to_meter(i:int=DisplayServer.SCREEN_OF_MAIN_WINDOW)->float:
	var d:float=DisplayServer.screen_get_dpi(i)
	return d/0.0254

static func set_is_on(c:Variant,k:StringName,v:int)->void:
	if v&0x01!=0:c.set(k,false)
	elif v&0x02!=0:c.set(k,true)

# Input APIs

static func set_axis(k:StringName,v:float)->void:
	var f:float=Input.get_action_strength(k)
	if is_zero_approx(v-f):return
	#
	if is_zero_approx(v):Input.action_release(k)
	else:Input.action_press(k,v)

static func set_button(k:StringName,v:bool)->void:
	var b:bool=Input.is_action_pressed(k)
	if v==b:return
	#
	if v:Input.action_press(k,1.0)
	else:Input.action_release(k)

## Setter version of [method Input.get_vector].
static func set_vector(k:Array[StringName],v:Vector2,d:float=0.0)->void:
	d*=d
	var f:float=v.length_squared();
	if is_zero_approx(f-d) or f<d:v=Vector2.ZERO
	var u:Vector2=Input.get_vector(k[0],k[1],k[2],k[3])
	f=(v-u).length_squared()
	if is_zero_approx(f):return
	#
	if v.x<0.0:Input.action_press(k[0],-v.x)
	else:Input.action_release(k[0])
	if v.x>0.0:Input.action_press(k[1], v.x)
	else:Input.action_release(k[1])
	if v.y<0.0:Input.action_press(k[2],-v.y)
	else:Input.action_release(k[2])
	if v.y>0.0:Input.action_press(k[3], v.y)
	else:Input.action_release(k[3])

static func set_click(k:StringName,t:float=0.1)->void:
	set_button(k,true)
	Juggler.instance.delay_call(
		func()->void:set_button(k,false),
		LangExtension.k_empty_array,t)

static func set_swipe(a:Array[StringName],b:StringName,v:Vector2,t:float=0.1)->void:
	set_vector(a,v);set_button(b,true)
	Juggler.instance.delay_call(
		func()->void:set_vector(a,Vector2.ZERO);set_button(b,false),
		LangExtension.k_empty_array,t)

# Event APIs

static var s_event_inited:bool
static var s_event_classes:PackedStringArray
static var s_event_scripts:Array[Object]
static var s_event_enums:Array[Variant]
static var s_event_indexes:Array[StringName]
static var s_event_values:Array[StringName]

static func event_init()->void:
	if s_event_inited:return
	s_event_inited=true
	#
	var n:StringName=LangExtension.k_empty_name
	var e:Array=LangExtension.k_empty_array
	event_add_type(n,InputEvent,e,n,n)
	event_add_type(&"MouseMotion",InputEventMouseMotion,e,n,&"position")
	event_add_type(&"MouseButton",InputEventMouseButton,PointerInput.k_buttons,&"button_index",&"pressed")
	event_add_type(&"Key",InputEventKey,KeyboardInput.k_keys,&"keycode",&"pressed")
	event_add_type(&"JoypadMotion",InputEventJoypadMotion,GamepadInput.k_axes,&"axis",&"axis_value")
	event_add_type(&"JoypadButton",InputEventJoypadButton,GamepadInput.k_buttons,&"button_index",&"pressed")
	event_add_type(&"ScreenDrag",InputEventScreenDrag,e,&"index",&"position")
	event_add_type(&"ScreenTouch",InputEventScreenTouch,e,&"index",&"pressed")

static func event_add_type(c:StringName,s:Variant,e:Variant,i:StringName,v:StringName)->void:
	if !s_event_inited:event_init()
	#
	var k:String="InputEvent"+c
	var p:int=s_event_classes.find(k);if p>=0:return
	s_event_classes.append(k)
	s_event_scripts.append(s)
	s_event_enums.append(e)
	s_event_indexes.append(i)
	s_event_values.append(v)

static func event_new_input(i:int)->InputEvent:
	if !s_event_inited:event_init()
	#
	return s_event_scripts[i].new()

static func event_get_enum(i:int)->Variant:
	if !s_event_inited:event_init()
	#
	return s_event_enums[i]

static func event_get_type(e:InputEvent)->int:
	if !s_event_inited:event_init()
	#
	if e!=null:return s_event_classes.find(e.get_class())
	return -1

static func event_get_index(e:InputEvent,i:int=-1)->int:
	if !s_event_inited:event_init()
	#
	if e!=null:
		if i<0:i=s_event_classes.find(e.get_class())
		var v:Variant=e.get(s_event_indexes[i])
		if v!=null:return v
	return -1

static func event_get_value(e:InputEvent,i:int=-1)->Variant:
	if !s_event_inited:event_init()
	#
	if e!=null:
		if i<0:i=s_event_classes.find(e.get_class())
		return e.get(s_event_values[i])
	return null
