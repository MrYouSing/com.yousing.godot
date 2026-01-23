## An input class for [url=https://developer.apple.com/design/Human-Interface-Guidelines/gestures#Specifications]gestures[/url].
class_name GestureInput extends Node

static var current:GestureInput

@export_group("Gesture")
@export_flags(
	"Unhandled",
	"Touch",
	"Tap",
	"Hold",
	"Double",
	"Swipe",
	"Drag",
	"Pan",
	"Rotate",
	"Zoom",
)var features:int=-1
# https://developer.apple.com/documentation/uikit/uigesturerecognizer/state-swift.enum/possible?language=objc#Constants
signal on_begin(e:GestureEvent)
signal on_change(e:GestureEvent)
signal on_end(e:GestureEvent)

var temp:GestureEvent=GestureEvent.new()

func set_enabled(b:bool)->void:
	set_process(b)
	if features&0x01!=null:set_process_unhandled_input(b)
	else:set_process_input(b)

func support(t:GestureType)->bool:
	return features&(1<<t)!=0

func contain(p:Vector2)->bool:
	return true

func fallback(s:Signal,t:GestureType)->void:
	print("{0}.{1} at {2}".format([GestureType.find_key(t),s.get_name(),"%.3f"%Application.get_time()]))

func fire_gesture(s:Signal,t:GestureType,p:Vector2)->void:
	if support(t)==false or !contain(p):return
	if s.is_null() or !s.has_connections():fallback(s,t);return
	#
	temp.type=t
	temp.position=p
	temp.time=Application.get_time()
	s.emit(temp)

func begin_gesture(t:GestureType,p:Vector2)->void:
	temp.origin=p
	fire_gesture(on_begin,t,p)

func change_gesture(t:GestureType,p:Vector2)->void:
	fire_gesture(on_change,t,p)

func end_gesture(t:GestureType,p:Vector2)->void:
	fire_gesture(on_end,t,p)

func _ready()->void:
	var b:bool=features&0x01!=0
	set_process_input(!b)
	set_process_unhandled_input(b)
	#
	if current==null:current=self

func _exit_tree()->void:
	if self==current:current=null

enum GestureType {
	None,
	# Hit Finger
	Touch,
	Tap,
	Hold,
	Double,
	# Move Finger
	Swipe,
	Drag,
	# Two Finger
	Pan,
	Rotate,
	Zoom,
}

class GestureEvent:
	var type:GestureType
	var origin:Vector2
	var position:Vector2
	var time:float
	var value:float
