class_name UIExtension

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

static func get_button()->int:
	if s_button>=0:return s_button
	# TODO: Button.pressed is a deferred signal,we don't know which mouse button is pressed.
	# TODO: Fallback detection is based on which higher button is held.
	var i:int=3
	var p:PointerInput=PointerInput.current
	if p!=null:
		while i>0:i-=1;if p.mouse_on(i):return i
	else:
		var m:int=DisplayServer.mouse_get_button_state()
		while i>0:i-=1;if m&(1<<i)!=0:return i
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
