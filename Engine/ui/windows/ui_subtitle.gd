## A subtitle window for [Media].
class_name UISubtitle extends Node

static var s_script:Object=preload("res://addons/rubonnek.subtitles_importer/subtitles.gd")
static var s_extensions:PackedStringArray

static func get_extensions()->PackedStringArray:
	if s_extensions.is_empty():
		if s_script!=null:
			var a:PackedStringArray=s_script.supported_extensions;var n:int=a.size()
			s_extensions.resize(n);for i in n:s_extensions[i]="."+a[i]
		else:
			s_extensions.append(".unknown")
	return s_extensions

static func load_from_file(f:String)->Resource:
	if s_script!=null:
		var r:Resource=s_script.new();var e:Error=r.load_from_file(f)
		if e!=Error.OK:print("Load({0})={1}".format([f,error_string(e)]))
		return r
	return null

@export_group("Subtitle")
@export var category:StringName
@export var event:StringName
@export var offset:float
@export var media:Media:
	set(x):if x!=media:media=x;set_process(x!=null)
@export var label:Node

var url:String:
	set(x):if x!=url:url=x;self.load(x)

var time:float=-1.0:
	set(x):if not is_zero_approx(x-time):time=x;seek(x)

var _call:int=Juggler.k_invalid_id
var _list:Array[Dictionary]

func clear()->void:
	_list.clear();time=-1.0

func find(t:float)->int:
	var i:int=-1;for it in _list:
		i+=1;if t>=it.get(0,0.0) and t<=it.get(1,0.0):return i
	return -1

func get_time(i:int)->Vector2:
	var d:Dictionary=_list[i];return Vector2(d.get(0,0.0),d.get(1,0.0))

func get_text(i:int)->String:
	return _list[i].get(2,LangExtension.k_empty_string)

func set_item(i:int,b:float,e:float,s:String)->void:
	var n:int=_list.size()
	while i>=n:_list.append(Dictionary());n+=1
	#
	var d:Dictionary=_list[i]
	d.set(0,b);d.set(1,e);d.set(2,s)

func load(f:String)->void:
	clear()
	f=IOExtension.file_variant(f,get_extensions())
	if not f.is_empty():
		var r:Resource=null;if IOExtension.is_sandbox(f):
			r=IOExtension.load_asset(f,"Subtitles")
		else:
			r=Asset.auto_asset(f,load_from_file)
		if r!=null:_list.assign(r.get_entries())

func seek(t:float)->void:
	var i:int=find(t);if i>=0:
		var r:Vector2=get_time(i);var j:int=1
		var n:int=_list.size();var s:Vector2=r
		while i+j<n:# Check multi-language.
			s=get_time(i+j)
			if r.is_equal_approx(s):j+=1
			else:break
		if is_zero_approx(r.y-s.x):# Check time ranges.
			if offset<=0.0:r.y+=offset# Ensure full.
			else:r.y=r.x+offset# Fixed duration.
		render(i,j,(t-r.x)/(r.y-r.x))
	else:
		render(i,0,0.0)

func render(i:int,c:int,f:float)->void:
	var s:String=LangExtension.k_empty_string
	if i>=0:s=get_text(i)
	if label!=null:
		if label.get_script()==null:
			label.set(&"text",s)
		else:
			label.set(&"model",s)
			label.set(&"progress",clampf(f,0.0,1.0))

func shoot(t:Vector2,s:String)->void:
	t.y=MathExtension.time_fade(0.0,s.length(),t.y)
	#
	var j:Juggler=Juggler.instance;j.kill_call(_call)
	clear();set_process(false)# Pause
	set_item(0,0.0,t.y,s)# Inject
	_call=j.update_call(update_shoot,LangExtension.k_empty_array,t.x,t.y)

func update_shoot()->void:
	var f:float=Juggler.current.progress()
	render(0,1,f);if f>=1.0:
		if is_zero_approx(offset):
			clear_shoot()
		else:
			var j:Juggler=Juggler.instance;j.kill_call(_call)
			_call=j.delay_call(clear_shoot,LangExtension.k_empty_array,-offset)

func clear_shoot()->void:
	var j:Juggler=Juggler.instance;j.kill_call(_call)
	_call=Juggler.k_invalid_id
	render(-1,0,0.0);set_process(media!=null)# Resume
	var u:String=url;if not u.is_empty():self.load(u)# Revert

func speak(o:Object,s:String)->void:
	var t:Vector2=Vector2(o.get_meta(&"delay",0.0),o.get_meta(&"duration",1.0))
	shoot(t,tr(s,category))

func _ready()->void:
	if label==null:label=GodotExtension.assign_node(self,"Label")
	if not event.is_empty():UIManager.instance.events.add_listener(event,shoot)
	set_process(media!=null)

func _process(d:float)->void:
	if media!=null:
		url=media.url
		if media.is_playing():
			time=media.get_position()
