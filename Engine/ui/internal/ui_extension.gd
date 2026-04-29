class_name UIExtension

static func copy_transform(a:Control,b:Control)->void:
	if a!=null and b!=null:
		var m:Transform2D=a.get_global_transform_with_canvas()
		b.set_global_position(m.origin)
		b.rotation=m.get_rotation()
		#
		b.scale=a.scale
		b.pivot_offset_ratio=a.pivot_offset_ratio
		b.size=a.size

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
