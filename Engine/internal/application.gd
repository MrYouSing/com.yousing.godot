## Provides access to application runtime data.
class_name Application

# Engine APIs

static var s_app_inited:bool
static var s_app_debug:int=-1
static var s_app_platform:String
static var s_app_locale:String
static var s_app_frames:int=-1
static var s_app_time:float=-1.0
static var s_app_fps:int=-1
static var s_app_delta:float=-1.0
static var s_app_resolution:Vector2=Vector2.ZERO
static var s_app_config:ConfigFile
static var s_app_plugins:Dictionary[StringName,Dictionary]
static var s_bm_names:Array[String]
static var s_bm_times:Array[float]
# Events
static var on_locale:Signal=LangExtension.new_signal(Application,&"on_locale")
static var on_flush:Signal=LangExtension.new_signal(Application,&"on_flush")
static var on_focus:Signal=LangExtension.new_signal(Application,&"on_focus")
static var on_pause:Signal=LangExtension.new_signal(Application,&"on_pause")

  # Shortcut APIs

static var max_fps:int=-1:
	get:return max_fps if max_fps>0 else roundi(DisplayServer.screen_get_refresh_rate(max_fps))

static func get_tree()->SceneTree:return Engine.get_main_loop() as SceneTree

  # Platform APIs

static func get_platform()->String:
	if !s_app_platform.is_empty():return s_app_platform
	return OS.get_name()

static func get_locale()->String:
	if !s_app_locale.is_empty():return s_app_locale
	var s:String=OS.get_locale()
	#
	var l:PackedStringArray=s.split("_")
	if l.size()>2:return l[0]+"_"+l[2]
	else:return s

static func set_locale(l:String)->void:
	if l==s_app_locale:return
	s_app_locale=l
	#
	TranslationServer.set_locale(l)
	on_locale.emit(l)

  # Statistics APIs

static func get_frames()->int:
	if s_app_frames>=0:return s_app_frames
	return Engine.get_process_frames()

static func get_time()->float:
	if s_app_time>=0.0:return s_app_time
	return Time.get_ticks_msec()*0.001

static func get_fps()->int:
	if s_app_fps>=0:return s_app_fps
	var n:int=Engine.max_fps
	if n<=0:
		n=max_fps
		if n<=0:n=60
	return n

static func get_delta()->float:
	if s_app_delta>=0.0:return s_app_delta
	return 1.0/get_fps()

static func get_resolution()->Vector2:
	if !s_app_resolution.is_zero_approx():return s_app_resolution
	var s:Vector2i=get_tree().root.size
	return Vector2(s.x,s.y)

static func set_resolution(s:Vector2,m:DisplayServer.WindowMode=-1,r:int=-2)->void:
	if s.length_squared()!=0.0:
		get_tree().root.size=Vector2i(s.x,s.y)
	if m>=0:
		DisplayServer.window_set_mode(m)
	if r>=-1:
		if r<0:r=max_fps
		Engine.max_fps=r

  # Runtime APIs

static func get_config()->ConfigFile:
	if s_app_config==null:
		set_config(ConfigFile.new(),"res://app.cfg","user://app.cfg")
	return s_app_config

static func set_config(c:ConfigFile,s:String,d:String)->void:
	if s_app_config!=null:
		LangExtension.shoot_signal(on_flush,s_app_config,LangExtension.k_empty_array)
	s_app_config=c
	if s_app_config!=null:
		var b:bool=!d.is_empty();if b and FileAccess.file_exists(d):s=d
		if !s.is_empty() and FileAccess.file_exists(s):s_app_config.load(s)
		if b:on_flush.connect(s_app_config.save.bind(d))

static func get_plugin(k:StringName,a:bool)->Dictionary[StringName,Callable]:
	if s_app_plugins.has(k):
		return s_app_plugins[k]
	elif a:
		var v:Dictionary[StringName,Callable]={}
		s_app_plugins[k]=v;return v
	return LangExtension.k_empty_dictionary

static func set_plugin(k:StringName,v:Dictionary[StringName,Callable])->void:
	if s_app_plugins.has(k):
		s_app_plugins[k].assign(v)
	else:
		s_app_plugins[k]=v

static func begin_benchmark(c:String)->void:
	s_bm_names.push_back(c)
	s_bm_times.push_back(get_time())

static func end_benchmark()->void:
	var c:String=s_bm_names.pop_back()
	var t:float=s_bm_times.pop_back()
	var d:float=get_time()
	debug(c.format([t,d-t,d]))

  # User APIs

static func debug(m:String,l:int=0)->void:
	if s_app_debug&(1<<l)!=0:match l:
		0:print(m)
		1:print_debug(m)
		2:print_rich("[color=ead07e]● WARNING: %s[/color]"%m);push_warning(m)
		3:printerr(m);push_error(m)

static func init()->void:
	if s_app_inited:return
	s_app_inited=true
	get_tree().root.tree_exited.connect(exit)
	#
	var c:ConfigFile=get_config();if c!=null:
		var v:String=ProjectSettings.get_setting("application/config/version","0.0.0.0")
		var s:String=c.get_value("Global","Version",v)
		if s!=v:debug("Application.version changed:{0}->{1}".format([s,v]),2)
		set_locale(c.get_value("Global","Locale",s_app_locale))
		#
		var r:Vector2=get_resolution()
		r.x=c.get_value("Window","Width",r.x)
		r.y=c.get_value("Window","Height",r.y)
		set_resolution(r,c.get_value("Window","Mode",-1),c.get_value("Window","Rate",-1))
	debug("Application init() at %03f."%get_time())

static func exit()->void:
	if !s_app_inited:return
	s_app_inited=false
	get_tree().root.tree_exited.disconnect(exit)
	#
	var c:ConfigFile=s_app_config;if c!=null:
		c.set_value("Global","Engine","0x%08X"%(Engine.get_version_info().hex))
		c.set_value("Global","Version",ProjectSettings.get_setting("application/config/version","0.0.0.0"))
		c.set_value("Global","Locale",s_app_locale)
		#
		var r:Vector2=get_resolution()
		var f:int=Engine.max_fps;if is_equal_approx(max_fps,f):f=-1
		c.set_value("Window","Width",int(r.x))
		c.set_value("Window","Height",int(r.y))
		c.set_value("Window","Mode",DisplayServer.window_get_mode())
		c.set_value("Window","Rate",f)
	flush()
	debug("Application exit() at %03f."%get_time())

static func quit():
	get_tree().quit()
	debug("Application quit() at %03f."%get_time())
	exit()

static func flush()->void:
	on_flush.emit()
	debug("Application flush() at %03f."%get_time())

static func focus(b:bool)->void:
	on_focus.emit(b)
	debug("Application focus({0}) at {1}.".format([b,"%03f."%get_time()]))

static func pause(b:bool)->void:
	get_tree().paused=b
	on_pause.emit(b)
	debug("Application pause({0}) at {1}.".format([b,"%03f."%get_time()]))

static func try_flush()->void:
	if !s_app_inited:flush()
