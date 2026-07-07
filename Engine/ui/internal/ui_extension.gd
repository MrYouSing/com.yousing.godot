class_name UIExtension

# Geometry

static func get_canvas_scale(i:int=-1)->Vector2:
	if i>=0:
		var b:bool=i%2==0;i/=2
		var c:UICanvas=UICanvas.instances[i]
		if c!=null:
			if b:return c.screen_to_ui
			else:return c.ui_to_screen
	return Vector2.ONE

static func get_control_rect(c:Control)->Rect2:
	if c!=null:
		return c.get_rect()
	return Rect2(Vector2.ZERO,Application.get_resolution())

static func get_control_point(c:Control,a:Vector2,o:Vector2,i:int=-1)->Vector2:
	var r:Rect2=get_control_rect(c)
	a=r.position+r.size*a+o
	if i>=0:a*=get_canvas_scale(i)
	return a

static func copy_transform(a:Control,b:Control)->void:
	if a!=null and b!=null:
		var m:Transform2D=a.get_global_transform_with_canvas()
		b.set_global_position(m.origin)
		b.rotation=m.get_rotation()
		#
		b.scale=a.scale
		b.pivot_offset_ratio=a.pivot_offset_ratio
		b.size=a.size

static func resample_transform(t:UITransform,c:Control,f:float)->void:
	if t==null or c==null:return
	var tmp:Control=t.control
	var s:Vector2=t.size_delta
	var a:Vector2=t.anchor_min
	var z:Vector2=t.anchor_max
	var p:Vector2=t.pivot
	#
	t.begin()
	t.control=c
	t.size_delta=s*f
	t.anchor_min=p+(a-p)*f
	t.anchor_max=p+(z-p)*f
	t.end()
	# Revert the t.
	t.begin()
	t.size_delta=s
	t.anchor_min=a
	t.anchor_max=z
	t.pivot=p
	t.control=tmp

# Views

static func set_content(o:Object,k:StringName,v:Variant,i:int)->void:
	if o==null:return
	#
	o.set(k,v);if i!=0:o.visible=i==1

static func set_text(o:Object,s:String,b:bool=true)->void:
	if o==null:return
	var i:int;if b:
		if s.is_empty():i=-1
		else:i=1
	#
	o.set(&"text",s);if i!=0:o.visible=i==1

static func set_texture(o:Object,t:Texture,b:bool=true)->void:
	if o==null:return
	var i:int;if b:
		if t==null:i=-1
		else:i=1
	#
	o.set(&"texture",t);if i!=0:o.visible=i==1

static func scale_theme_constant(c:Control,k:StringName,f:float)->void:
	if c==null:return
	if not c.has_theme_constant(k):return
	#
	c.remove_theme_constant_override(k)
	var i:int=roundi(c.get_theme_constant(k)*f)
	c.add_theme_constant_override(k,i)

static func scale_theme_font_size(c:Control,k:StringName,f:float)->void:
	if c==null:return
	if not c.has_theme_font_size(k):return
	#
	c.remove_theme_font_size_override(k)
	var i:int=roundi(c.get_theme_font_size(k)*f)
	c.add_theme_font_size_override(k,i)

static func scale_label_settings(a:LabelSettings,b:LabelSettings,f:float)->void:
	if a==null or b==null:return
	a.font_size=roundi(b.font_size*f)
	a.line_spacing=b.line_spacing*f
	a.paragraph_spacing=b.paragraph_spacing*f
	a.outline_size=roundi(b.outline_size*f)
	a.shadow_size=roundi(b.shadow_size*f)
	a.shadow_offset=b.shadow_offset*f

# Events

static var s_clicking:bool
static var s_button:int=-1

static func get_button(n:int=3)->int:
	if s_button>=0:return s_button
	#
	var m:int=DisplayServer.mouse_get_button_state()
	var p:PointerInput=PointerInput.current;var i:int=n
	if p!=null:# TODO: Force-update the latest buttons.
		var e:PointerInput.PointerEvent=p.get_mouse()
		e.buttons=m;while i>0:i-=1;if p.mouse_down(i):return i
	# TODO: Fallback detection is based on which higher button is held.
	i=n;while i>0:i-=1;if m&(1<<i)!=0:return i
	return -1

static func select_node(n:Node)->void:
	if n!=null:
		if n.has_method(&"_on_select"):n._on_select()
		elif n is Control:n.grab_focus()
		else:GodotExtension.set_enabled(n,true)

static func deselect_node(n:Node)->void:
	if n!=null:
		if n.has_method(&"_on_deselect"):n._on_deselect()
		elif n is Control:n.release_focus()
		else:GodotExtension.set_enabled(n,false)
