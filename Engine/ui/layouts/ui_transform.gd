## A [url=https://docs.unity3d.com/Documentation/ScriptReference/RectTransform.html]RectTransform[/url] implementation for Godot.
@tool
class_name UITransform extends Node

const k_hidden_pos:Vector2=Vector2.ONE*-1024.0
static var s_float_helper:Array[float]=[0.0,0.5,1.0,-1.0,NAN]

static func enum_to_vec2(e:int,f:float,u:bool=false)->Vector2:
	s_float_helper[3]=f;var m:int=0
	var v:Vector2=Vector2.ZERO;var i:int
	#
	i=e%4;v.x=s_float_helper[i];
	if i==3:m+=1
	#
	i=e/4;v.y=s_float_helper[i];
	if i==3:m+=2
	elif u:v.y=1.0-v.y
	#
	s_float_helper[4]=m;return v

static func preset_to_vec2(p:int)->Vector2:
	return enum_to_vec2(k_layout_presets[p],0.0,false)

static func get_position(c:Control,u:Vector2,w:bool=true)->Vector2:
	if c!=null:
		var t:Transform2D=c.get_global_transform_with_canvas() if w else c.get_transform()
		var p:Vector2=c.size*c.pivot_offset_ratio+c.pivot_offset;p*=t.get_scale()
		var x:float=t.get_rotation();var y:float=sin(x);x=cos(x)
		u.x-=p.x*x-p.y*y;u.y-=p.x*y+p.y*x
	return u

static func set_anchor_and_offset(c:Control,a:Vector2,z:Vector2,p:Vector2,q:Vector2)->void:
	if c==null:return
	c.set_anchor_and_offset(SIDE_LEFT  ,a.x,p.x,true)
	c.set_anchor_and_offset(SIDE_RIGHT ,z.x,q.x,true)
	c.set_anchor_and_offset(SIDE_TOP   ,a.y,p.y,true)
	c.set_anchor_and_offset(SIDE_BOTTOM,z.y,q.y,true)

# <!-- Macro.Patch AutoGen
const k_layout_presets:Dictionary[Control.LayoutPreset,int]={
Control.LayoutPreset.PRESET_TOP_LEFT:0,
Control.LayoutPreset.PRESET_CENTER_TOP:1,
Control.LayoutPreset.PRESET_TOP_RIGHT:2,
Control.LayoutPreset.PRESET_TOP_WIDE:3,
Control.LayoutPreset.PRESET_CENTER_LEFT:4,
Control.LayoutPreset.PRESET_CENTER:5,
Control.LayoutPreset.PRESET_CENTER_RIGHT:6,
Control.LayoutPreset.PRESET_HCENTER_WIDE:7,
Control.LayoutPreset.PRESET_BOTTOM_LEFT:8,
Control.LayoutPreset.PRESET_CENTER_BOTTOM:9,
Control.LayoutPreset.PRESET_BOTTOM_RIGHT:10,
Control.LayoutPreset.PRESET_BOTTOM_WIDE:11,
Control.LayoutPreset.PRESET_LEFT_WIDE:12,
Control.LayoutPreset.PRESET_VCENTER_WIDE:13,
Control.LayoutPreset.PRESET_RIGHT_WIDE:14,
Control.LayoutPreset.PRESET_FULL_RECT:15,
}

@export_group("Transform")
@export var control:Control:
	set(x):control=x;_on_dirty()
@export var unity:bool=true:## Use the unity-style coordinate system?
	set(x):unity=x;_on_dirty()
@export var anchored_position:Vector2:
	set(x):anchored_position=x;_on_dirty()
@export var size_delta:Vector2=Vector2.ONE*100.0:
	set(x):size_delta=x;_on_dirty()
@export var anchor_preset:Control.LayoutPreset=-1:
	set(x):anchor_preset=x;if x>=0:_on_preset(x,-1)
@export var anchor_min:Vector2=MathExtension.k_vec2_half:
	set(x):anchor_min=x;_on_dirty()
@export var anchor_max:Vector2=MathExtension.k_vec2_half:
	set(x):anchor_max=x;_on_dirty()
@export var pivot_preset:Control.LayoutPreset=-1:
	set(x):pivot_preset=x;if x>=0:_on_preset(-1,x)
@export var pivot:Vector2=MathExtension.k_vec2_half:
	set(x):pivot=x;_on_dirty()
# Macro.Patch -->
@export_tool_button("Refresh") var do_refresh:Callable=func()->void:dirty=true;refresh()

var dirty:bool

func begin()->void:dirty=true
func end()->void:refresh()

func refresh()->void:
	if !dirty:return
	if control==null:return
	dirty=false
	#
	var a:Vector2=anchored_position
	var o:Vector2=size_delta;var p:Vector2=pivot;
	var q:Vector2=a+(Vector2.ONE-p)*o;o=a-p*o
	a=anchor_min;var z:Vector2=anchor_max
	if unity:
		p.y=1.0-p.y;var f:float
		f=1.0-a.y;a.y=1.0-z.y;z.y=f
		f=-o.y;o.y=-q.y;q.y=f
	control.pivot_offset_ratio=Vector2(p)
	set_anchor_and_offset(control,a,z,o,q)

func anchor(a:int=-1,z:int=-1,p:int=-1)->void:
	var r:Vector2=anchored_position;
	var s:Vector2=size_delta;
	var t:Vector2=s;var v:Vector2
	if a>=0:
		anchor_min=enum_to_vec2(a,0.0,unity)
		a=s_float_helper[4]
		if a&0x1!=0:r.x=0.0;s.x=0.0
		if a&0x2!=0:r.y=0.0;s.y=0.0
	if z>=0:
		anchor_max=enum_to_vec2(z,1.0,unity)
	if p>=0:
		v=enum_to_vec2(p,0.0,unity)
		if s_float_helper[4]==0.0:pivot=v
	if s!=t:
		anchored_position=r
		size_delta=s

func rect(r:Vector4)->void:
	anchored_position=Vector2(r.x,r.y)
	size_delta=Vector2(r.z,r.w)

func padding(p:Vector4)->void:
	var a:Vector2=Vector2(p.x,p.y)
	var z:Vector2=Vector2(p.z,p.w)
	anchored_position=-0.5*(z-a)
	size_delta=-(a+z)

func _on_preset(a:Control.LayoutPreset,p:Control.LayoutPreset)->void:
	var tmp:bool=dirty;dirty=true;
	var i:int=k_layout_presets[a] if a>=0 else -1
	var j:int=k_layout_presets[p] if p>=0 else -1
	anchor(i,i,j)
	dirty=false if Engine.is_editor_hint() else tmp;_on_dirty()

func _on_dirty()->void:
	if dirty:return
	dirty=true
	#
	if Engine.is_editor_hint():
		refresh()
	elif control!=null:
		if Juggler.exists:Juggler.instance.delay_call(refresh,LangExtension.k_empty_array,0.0)
		else:refresh.call_deferred()

func _ready()->void:
	dirty=true
	if !Engine.is_editor_hint():
		if control==null:control=GodotExtension.assign_node(self,"Control")
	refresh()
