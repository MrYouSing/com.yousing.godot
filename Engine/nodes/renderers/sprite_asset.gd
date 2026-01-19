## A lightweight [SpriteFrames] for custom sprite rendering.
class_name SpriteAsset extends Resource

@export_group("Sprite")
@export var fps:float=24.0
@export var pivot:Vector2=MathExtension.k_vec2_half
@export var paths:Array[String]
@export var textures:Array[Texture2D]

var is_inited:bool
var clips:Array[Clip]
var library:Dictionary[StringName,Clip]

func new_clip(a:Atlas)->Clip:
	if a==null:return null
	#
	var c:Clip=Clip.new()
	c.context=a
	c.name=a.name
	c.fps=a.fps
	#
	if a.next!=null:
		c.loop=Animation.LOOP_LINEAR
	var f:Frame;for it in a.sprites:
		f=Frame.new();f.object=it
		c.frames.append(f)
	for it in a.events:
		f=c.get_frame(it.time)
		if f!=null:f.key=it.name
	return c

func new_sheet(t:Texture2D,p:String)->Sheet:
	if t==null:return null
	#
	var s:Sheet=Sheet.new()
	s.set_texture(t,p)
	if s.pivot.x<0.0:s.pivot.x=pivot.x
	if s.pivot.y<0.0:s.pivot.y=pivot.y
	return s

func new_segment(p:String)->Segment:
	var s:Segment=Segment.new()
	s.context=self;s.set_json(p)
	return s

func load_texture(i:int)->void:
	var t:Texture2D=textures[i]
	var p:String=paths[i]
	if t==null and FileAccess.file_exists(p):t=load(p)
	else:p=t.resource_path
	#
	var a:Atlas
	if t!=null:a=new_sheet(t,p)
	else:a=new_segment(p)
	if a.fps<0.0:a.fps=fps
	if a.events.is_empty():
		p=LangExtension.combine_path(LangExtension.directory_name(p),a.name+"_events.json")
		load_event(a.events,p)
	#
	var c:Clip=new_clip(a);clips.append(c)
	library[c.name]=c

func load_event(e:Array[Marker],p:String)->void:
	p=Loader.load_text(p)
	if p.is_empty():return
	#
	LangExtension.array_add_maps(e,JSON.parse_string(p),Marker)

func init()->void:
	if is_inited:return
	is_inited=true
	#
	clips.clear()
	var n:int=maxi(paths.size(),textures.size())
	if textures.size()<n:textures.resize(n)
	if paths.size()<n:paths.resize(n)
	for i in n:load_texture(i)

func get_clip(i:int)->Clip:
	if !is_inited:init()
	#
	if i>=0 and i<clips.size():return clips[i]
	else:return null

func find_clip(k:StringName)->Clip:
	if !is_inited:init()
	#
	return library.get(k,null)

class Atlas:
	var name:StringName
	var sprites:Array[Sprite]
	var fps:float=-1.0
	var next:Variant
	var events:Array[Marker]

	func set_json(j:String)->void:
		j=Loader.load_text(j)
		if j.is_empty():return
		LangExtension.map_to_object(JSON.parse_string(j),self)

class Segment extends Atlas:
	var context:SpriteAsset
	var source:Atlas:
		set(x):source=x;_on_dirty()
	var segment:String:
		set(x):segment=x;_on_dirty()

	func _set(k:StringName,v:Variant)->bool:
		if k==&"$source":if context!=null:
			var c:Clip=context.find_clip(v)
			if c!=null:source=c.context;return true
		return false

	func _on_dirty()->void:
		if source==null or segment.is_empty():return
		#
		sprites.clear()
		var i:int;var j:int
		for it in segment.split(","):
			i=it.find("~")
			if i<=0:
				sprites.append(source.sprites[it.to_int()])
			else:j=it.substr(i+1).to_int();i=it.substr(0,i).to_int();for p in (j-i)+1:
				sprites.append(source.sprites[i+p])
		#
		if source.events.is_empty():
			events.append_array(source.events)

class Sheet extends Atlas:
	var texture:Texture2D
	var size:Vector4
	var rows:int
	var cols:int
	var count:int:
		get:return count if count>0 else (rows*cols+count)
	var border:int
	var pivot:Vector2=-Vector2.ONE

	func set_flag(p:String,k:String,v:String)->bool:
		match k:
			"_":cols=v.to_int()
			"x":rows=v.to_int()
			"c":count=v.to_int()
			"b":border=v.to_int()
			"p":pivot.x=v.to_float()
			"q":pivot.y=v.to_float()
			"r":fps=v.to_float()
			"n":# Next
				p=p.substr(p.rfind("n")+1)
				if p.is_valid_int():next=p.to_int()
				else:next=p
				return false
		return true

	func new_sprite(x:int,y:int)->Sprite:
		var s:Sprite=Sprite.new()
		s.sheet=self
		if border>0:
			s.index=-1
			s.rect.position=Vector2(border+size.x*x,border+size.y*y)
			s.rect.size=Vector2(size.x-border*2.0,size.y-border*2.0)
		else:
			s.index=cols*y+x
		return s

	func set_texture(t:Texture2D,p:String)->void:
		if t==null:return
		if p.is_empty():p=t.resource_path
		var d:String=LangExtension.directory_name(p)
		p=LangExtension.file_name_only(p)
		var i:int=p.rfind("_")
		#
		texture=t
		if i<0:
			name=p
		else:
			name=p.substr(0,i)
			#
			var k:String="_";var v:String=""
			p=p.substr(i+1);i=-1
			for it in p:
				i+=1
				if it=="-" or it=="." or it.is_valid_int():
					v+=it
				else:
					set_flag(p,k,v)
					k=it;v=""
					if it=="n":break
			if i>=0:set_flag(p,k,v)
		#
		p=LangExtension.combine_path(d,name+".json")
		set_json(p)
		var v:Vector2=t.get_size()
		size=Vector4(v.x/cols,v.y/rows,v.x,v.y)
		#
		sprites.clear();i=0;var n:int=count
		for y in rows:for x in cols:
			sprites.append(new_sprite(x,y))
			i+=1;if i>=n:post_texture();return
		post_texture()

	func post_texture()->void:
		if border>0:
			var b:Vector2=Vector2(border,border)
			var s:Vector2=Vector2(size.x,size.y)
			pivot=(s*pivot-b)/(s-2.0*b)
			size.x-=2.0*border;size.y-=2.0*border

class Sprite:
	var sheet:Sheet
	var index:int
	var rect:Rect2

	var offset:Vector2=Vector2(NAN,NAN):
		get:
			if is_nan(offset.x):
				var s:Sheet=sheet;if s!=null:
					var v:Vector2=rect.size
					if is_zero_approx(v.length_squared()):
						var w:Vector4=s.size;v=Vector2(w.x,w.y)
					offset=v*-s.pivot
			return offset

class Marker:
	var time:float
	var name:StringName
