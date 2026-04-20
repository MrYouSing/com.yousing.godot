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
