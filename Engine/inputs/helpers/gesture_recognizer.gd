## A simple [url=https://developer.apple.com/documentation/uikit/uigesturerecognizer]GestureRecognizer[/url] implementation for Godot.
class_name GestureRecognizer extends GestureInput

@export_group("Recognizer")
@export var input:PointerInput
@export var tap_args:Vector4=Vector4(0.0,0.25,0.0,-10.0)
@export var hold_args:Vector4=Vector4(0.5,-1.0,0.0,-10.0)
@export var swipe_args:Vector4=Vector4(0.0,0.5,0.25,0.0)
@export var drag_args:Vector4=Vector4(0.125,-1.0,0.01,0.0)

var engine:bool
var event:InputEventScreenTouch
var pointers:Array[PointerInput.PointerEvent]
var events:Array[_GestureEvent]
var touch:_GestureEvent
var drag:_GestureEvent

func set_enabled(b:bool)->void:
	super.set_enabled(b)
	if !b:
		for it in events:if it!=null:it.clear()

func num_singles()->int:return 2

func not_single(i:int)->bool:# TODO: Unlock
	if pointers.size()>=2:return true
	var it:_GestureEvent;for j in num_singles():
		it=events[j];if it==null:continue
		if it.time>=0.0 and it.index!=i:return true
	return false

func try_event(g:_GestureEvent,e:InputEvent,b:bool)->void:# TODO: Unlock
	if g==null:return
	if g.time<0.0 or b:g.set_event(e,b)

func try_change(t:GestureType,p:Vector2,a:Vector2,b:Vector2)->Vector2:
	if a.is_equal_approx(b):
		return a
	else:
		change_gesture(t,p)
		return b

func to_distance(f:float)->float:
	if f>0.0:f*=InputExtension.pixel_to_meter()
	elif f<0.0:f*=-1.0
	return f

func in_range(t:float,s:float,a:Vector4)->bool:
	if t<a.x:return false
	if a.x<a.y and t>a.y:return false
	a.z=to_distance(a.z);a.w=to_distance(a.w)
	if s<a.z:return false
	if a.z<a.w and s>a.w:return false
	return true

func _ready()->void:
	engine=ProjectSettings.get_setting("input_devices/pointing/android/enable_pan_and_scale_gestures")
	#
	if touch==null:touch=TouchEvent.new()
	if drag==null:drag=DragEvent.new()
	if events.is_empty():
		event=InputEventScreenTouch.new()
		events=[touch,drag]
		if engine:
			push_warning("GestureType.Rotate is missed because of godot gesture detection.")
			if support(GestureType.Pan):events.append(PanEvent.new())
			else:events.append(null)
			if support(GestureType.Zoom):events.append(ZoomEvent.new())
			else:events.append(null)
		else:
			if features&(0x07<<GestureType.Pan)!=0:events.append(TransformEvent.new())
	#
	for it in events:if it!=null:it.context=self;it.clear()
	if input==null:input=PointerInput.current
	super._ready()

func _input(e:InputEvent)->void:_on_input(e)
func _unhandled_input(e:InputEvent)->void:_on_input(e)

func _on_input(e:InputEvent)->void:
	if e is InputEventScreenTouch:
		if not_single(e.index):return
		#
		if e.pressed:
			begin_gesture(GestureType.Touch,e.position)
			touch.set_event(e,true)
		else:# TODO: Unlock
			if drag.time>=0.0:drag.set_event(e,false)
			else:touch.set_event(e,false)
			end_gesture(GestureType.Touch,e.position)
		if e.double_tap:begin_gesture(GestureType.Double,e.position)
	elif e is InputEventScreenDrag:# Trigger empty event when re-focus.
		if not_single(e.index):return
		#
		try_event(drag,e,!e.screen_relative.is_zero_approx())
	elif engine:
		if e is InputEventPanGesture:
			try_event(events[num_singles()],e,!e.delta.is_zero_approx())
		elif e is InputEventMagnifyGesture:
			try_event(events[num_singles()+1],e,!is_zero_approx(e.factor-1.0))

func _process(d:float)->void:
	if input!=null:# TODO: Unlock
		var n:int=Application.get_frames()
		pointers.clear();var c:int=input.get_touches(pointers)
		var s:int=_on_single(n,c)
		_on_dual(n,c,s)

func _on_single(n:int,c:int)->int:
		if c==1:
			var p:PointerInput.PointerEvent=pointers[0]
			event.index=p.index;event.position=p.position
			if n!=touch.timestamp:
				if drag.time>=0.0:pass# TODO: Unlock
				else:touch.set_event(event,!touch.diff(p.index))
			if n!=drag.timestamp:
				if drag.diff(p.index):drag.set_event(event,false)
		else:
			if n!=touch.timestamp:touch.set_event(null,false)
			if n!=drag.timestamp:drag.set_event(null,false)
		return num_singles()

func _on_dual(n:int,c:int,s:int)->void:
		if c==2:
			var a:PointerInput.PointerEvent=pointers[0]
			var b:PointerInput.PointerEvent=pointers[1]
			c=MathExtension.shorts_to_int(a.index,b.index)
			event.index=c;event.position=(a.position+b.position)*0.5
			var it:_GestureEvent;for i in events.size()-s:
				it=events[s+i];if it==null:continue
				if n!=it.timestamp:
					if it.diff(c):it.set_event(null,false)
		else:
			var it:_GestureEvent;for i in events.size()-s:
				it=events[s+i];if it==null:continue
				if n!=it.timestamp:it.set_event(null,false)

class _GestureEvent extends GestureInput.GestureEvent:
	var context:GestureRecognizer
	var index:int
	var timestamp:int
	var sub_time:float

	func clear()->void:
		time=-1.0
		index=-1
		timestamp=-1
		sub_time=-1.0

	func stop()->void:
		clear()

	func diff(i:int)->bool:
		return index>=0 and index!=i

	func get_time()->float:
		return Application.get_time()-time

	func get_distance()->float:
		return (position-origin).length_squared()

	func set_event(e:InputEvent,b:bool)->void:
		timestamp=Application.get_frames()
		if e!=null:position=e.position
		if time>=0.0:# On
			if !b:# Up
				_on_end(e)
				time=-1.0
				origin=Vector2.ZERO
				position=Vector2.ZERO
				index=-1
				sub_time=-1.0
				return
		else:# Off
			if b:# Down
				time=Application.get_time()
				origin=position
				_on_begin(e)
				return
		if b:
			_on_change(e)

	func _on_begin(e:InputEvent)->void:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)

	func _on_change(e:InputEvent)->void:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)

	func _on_end(e:InputEvent)->void:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)

class TouchEvent extends _GestureEvent:

	func stop()->void:# TODO: Unlock
		if sub_time>=0.0:# On
			sub_time=-2.0;context.end_gesture(GestureType.Hold,position)

	func _on_begin(e:InputEvent)->void:
		index=e.index

	func _on_change(e:InputEvent)->void:
		var c:GestureRecognizer=context
		if sub_time>=0.0:# On
			if !c.in_range(get_time(),get_distance(),c.hold_args):stop()
		elif sub_time>=-1.0:# Off
			var t:float=get_time()
			if c.in_range(t,get_distance(),c.hold_args):
				sub_time=time+t
				c.begin_gesture(GestureType.Hold,position)

	func _on_end(e:InputEvent)->void:
		var c:GestureRecognizer=context
		var d:_GestureEvent=c.drag
		if d.time>=0.0:# TODO: Unlock
			pass
		elif sub_time>=0.0:# On
			c.end_gesture(GestureType.Hold,position)
		elif c.in_range(get_time(),get_distance(),c.tap_args):
			c.begin_gesture(GestureType.Tap,position)

class DragEvent extends _GestureEvent:

	func _on_begin(e:InputEvent)->void:
		index=e.index
		context.touch.stop()

	func _on_change(e:InputEvent)->void:
		var c:GestureRecognizer=context
		if sub_time>=0.0:# On
			c.temp.origin=origin
			c.change_gesture(GestureType.Drag,position)
		else:# Off
			var t:float=get_time();var f:float=t
			if c.touch.sub_time>=0.0:# TODO: Unlock
				f=c.drag_args.x
			if c.in_range(f,get_distance(),c.drag_args):
				if c.touch.time>=0.0:# TODO: Unlock
					origin=c.touch.origin
				c.touch.stop()
				sub_time=time+t
				c.begin_gesture(GestureType.Drag,position)

	func _on_end(e:InputEvent)->void:
		var c:GestureRecognizer=context
		c.touch.stop()
		if sub_time>=0.0:# On
			c.end_gesture(GestureType.Drag,position)
		var v:Vector2=position-origin
		if c.in_range(get_time(),v.length_squared(),c.swipe_args):
			c.touch.time=-1.0# TODO: Unlock
			c.temp.value=MathExtension.clocking_at(v)
			c.begin_gesture(GestureType.Swipe,position)

class DualEvent extends _GestureEvent:

	func diff(i:int)->bool:
		if index==-2:index=i;return false# Eat two fingers.
		return super.diff(i)

	func _on_begin(e:InputEvent)->void:
		timestamp=-1
		index=-2# Eat two fingers at next frame.
		context.begin_gesture(type,position)

	func _on_change(e:InputEvent)->void:
		context.change_gesture(type,position)

	func _on_end(e:InputEvent)->void:
		context.end_gesture(type,position)

class PanEvent extends DualEvent:
	func _init()->void:
		type=GestureType.Pan

	func _on_change(e:InputEvent)->void:
		context.temp.origin=origin
		super._on_change(e)

class ZoomEvent extends DualEvent:
	func _init()->void:
		type=GestureType.Zoom

	func _on_begin(e:InputEvent)->void:
		value=1.0
		super._on_begin(e)

	func _on_change(e:InputEvent)->void:
		value*=e.factor
		context.temp.value=value
		super._on_change(e)

class TransformEvent extends DualEvent:
	var start:Vector2
	var point:Vector2
	var rotate:Vector2
	var scale:Vector2

	func _init()->void:
		type=GestureType.Rotate

	func diff(i:int)->bool:
		if index==-1:
			set_event(context.event,true)
			index=i
			return false
		elif i==index:
			set_event(context.event,true)
			return false
		return true

	func _on_begin(e:InputEvent)->void:
		var c:GestureRecognizer=context
		var i:Vector2=MathExtension.int_to_shorts(e.index)
		var p:Array[PointerInput.PointerEvent]=c.input.pointers
		start=p[i.y].position-p[i.x].position
		point=MathExtension.k_vec2_nan
		rotate=MathExtension.k_vec2_nan
		scale=MathExtension.k_vec2_nan
		#
		super._on_begin(e)
		if !c.engine:
			c.begin_gesture(GestureType.Pan,position)
			c.begin_gesture(GestureType.Zoom,position)

	func _on_change(e:InputEvent)->void:
		var c:GestureRecognizer=context
		var i:Vector2=MathExtension.int_to_shorts(e.index)
		var p:Array[PointerInput.PointerEvent]=c.input.pointers
		var v:Vector2=p[i.y].position-p[i.x].position
		var t:GestureEvent=c.temp
		#
		t.origin=origin
		t.value=MathExtension.clocking_at(v)-MathExtension.clocking_at(start)
		rotate=c.try_change(GestureType.Rotate,position,rotate,Vector2(t.value,0.0))
		if !c.engine:
			point=c.try_change(GestureType.Pan,position,point,position)
			t.value=v.length()/start.length()
			scale=c.try_change(GestureType.Zoom,position,scale,Vector2(t.value,0.0))

	func _on_end(e:InputEvent)->void:
		var c:GestureRecognizer=context
		super._on_end(e)
		if !c.engine:
			c.end_gesture(GestureType.Pan,position)
			c.end_gesture(GestureType.Zoom,position)
