## A canvas helper for ui auto-fit.
class_name UICanvas extends Node

enum AspectRatio {
	NoScaling,
	FitVertically,
	FitHorizontally,
	FitInside,
	FitOutside,
	Stretch,
	MatchWidth,
	MatchHeight,
}

static var instances:Array[UICanvas]=LangExtension.alloc_array(UICanvas,32)

static func register(n:Node,l:int,c:Callable)->void:
	if n==null:return
	var i:UICanvas=instances[l]
	if i!=null:i.refreshed.connect(c)
	else:n.get_viewport().size_changed.connect(c)

static func unregister(n:Node,l:int,c:Callable)->void:
	if n==null:return
	var i:UICanvas=instances[l]
	if i!=null:i.refreshed.disconnect(c)
	else:n.get_viewport().size_changed.disconnect(c)

static func fit_scale(m:AspectRatio,s:Vector2,d:Vector2)->Vector2:
	var a:float=s.x/s.y;var b:float=d.x/d.y
	match m:
		AspectRatio.FitHorizontally:return (d.x/s.x)*Vector2.ONE
		AspectRatio.FitVertically:return (d.y/s.y)*Vector2.ONE
		AspectRatio.FitInside:
			if a<b:return (d.y/s.y)*Vector2.ONE
			elif a>b:return (d.x/s.x)*Vector2.ONE
		AspectRatio.FitOutside:
			if a<b:return (d.x/s.x)*Vector2.ONE
			elif a>b:return (d.y/s.y)*Vector2.ONE
		AspectRatio.NoScaling:return Vector2.ONE
	return d/s

static func fit_control(p:AspectRatioContainer,n:Node,m:AspectRatio,s:Vector2)->void:
	if s.is_zero_approx():
		return
	if p!=null:
		match m:
			UICanvas.AspectRatio.FitHorizontally:p.stretch_mode=AspectRatioContainer.STRETCH_WIDTH_CONTROLS_HEIGHT
			UICanvas.AspectRatio.FitVertically:p.stretch_mode=AspectRatioContainer.STRETCH_HEIGHT_CONTROLS_WIDTH
			UICanvas.AspectRatio.FitInside:p.stretch_mode=AspectRatioContainer.STRETCH_FIT
			UICanvas.AspectRatio.FitOutside:p.stretch_mode=AspectRatioContainer.STRETCH_COVER
		p.ratio=s.aspect()
		return
	var c:Control=n;if c!=null:
		if m<=UICanvas.AspectRatio.Stretch:
			var d:Vector2=c.get_parent_area_size()
			s=UICanvas.fit_scale(m,s,d)*s
			s*=0.5;var h:Vector2=MathExtension.k_vec2_half
			UITransform.set_anchor_and_offset(c,h,h,-s,s)

@export_group("Canvas")
@export var layer:int
@export var canvas:Node:
	set(x):canvas=x;_on_dirty()
@export var resolution:Vector2i=Vector2i(1920,1080):
	set(x):resolution=x;_on_dirty()
@export var resample:float=1.0:
	set(x):resample=x;_on_dirty()
@export var mode:AspectRatio=1:
	set(x):mode=x;_on_dirty()
@export var pivot:Control.LayoutPreset=Control.PRESET_CENTER:
	set(x):pivot=x;_on_dirty()
@export var offset:Vector2:
	set(x):offset=x;_on_dirty()

signal refreshed()

var dirty:bool
var screen_to_ui:Vector2
var ui_to_screen:Vector2

func get_resolution()->Vector2:
	if resample<0.0:return resolution/-resample
	else:return resolution*resample

func get_screen()->Vector2:
	return DisplayServer.window_get_size()

func get_scale(m:AspectRatio,s:Vector2,d:Vector2)->Vector4:
	var a:float=signf(s.x-s.y);var b:float=signf(d.x-d.y)
	if a!=b:# Different Orientation.
		match m:
			AspectRatio.FitHorizontally:m=AspectRatio.FitVertically
			AspectRatio.FitVertically:m=AspectRatio.FitHorizontally
			AspectRatio.MatchWidth:m=AspectRatio.MatchHeight
			AspectRatio.MatchHeight:m=AspectRatio.MatchWidth
		var c:float=s.x;s.x=s.y;s.y=c
	match m:
		AspectRatio.MatchWidth:s.y=s.x*d.y/d.x;d=Vector2.ONE*(d.x/s.x)
		AspectRatio.MatchHeight:s.x=s.y*d.x/d.y;d=Vector2.ONE*(d.y/s.y)
		_:d=fit_scale(m,s,d)
	return Vector4(s.x,s.y,d.x,d.y)

func refresh()->void:
	if not dirty:return
	dirty=false
	#
	var w:Vector4=get_scale(mode,get_resolution(),get_screen())
	var s:Vector2=Vector2(w.x,w.y)
	var d:Vector2=Vector2(w.z,w.w)
	ui_to_screen=d
	screen_to_ui=Vector2(1.0/d.x,1.0/d.y)
	#
	if canvas==null:
		pass
	elif canvas is Control:
		var p:Vector2=UITransform.preset_to_vec2(pivot)
		canvas.pivot_offset=Vector2.ZERO
		canvas.pivot_offset_ratio=p
		UITransform.set_anchor_and_offset(canvas,p,p,-p*s+offset,(Vector2.ONE-p)*s+offset)
		canvas.scale=d
	elif canvas is CanvasLayer:
		return
	refreshed.emit()

func _on_dirty()->void:
	if ui_to_screen.x==0.0 or dirty:return
	dirty=true
	#
	if Juggler.exists:Juggler.instance.delay_call(refresh,LangExtension.k_empty_array,0.0)
	else:refresh.call_deferred()

func _enter_tree()->void:
	# Prepare
	if ui_to_screen.x!=0.0:return
	if canvas==null:canvas=GodotExtension.assign_node(self,"Control")
	dirty=true;refresh()
	get_viewport().size_changed.connect(_on_dirty)
	#
	if instances[layer]==null:instances[layer]=self

func _exit_tree()->void:
	# Cleanup
	get_viewport().size_changed.disconnect(_on_dirty)
	ui_to_screen=Vector2.ZERO;screen_to_ui=Vector2.ZERO;dirty=false
	#
	if self==instances[layer]:instances[layer]=null
