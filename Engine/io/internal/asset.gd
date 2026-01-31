## An advanced wrapper for [ResourceLoader].
class_name Asset

static var s_is_inited:bool
static var s_file_api:Dictionary[StringName,Callable]
static var s_cache_texts:Dictionary[String,String]
static var s_cache_tables:Dictionary[String,Array]

static func make_array(f:String,c:Variant)->Array:
	var t:Array[PackedStringArray]=load_table(f)
	if t.size()<=1:return LangExtension.k_empty_array
	return LangExtension.table_to_array(t,c)

static func load_array(a:Array,f:String,c:Variant,r:bool=true)->bool:
	if r:a.clear()
	var t:Array[PackedStringArray]=load_table(f)
	if t.size()<=1:return false
	LangExtension.array_add_table(a,t,c);return true

static func override_text(k:String,v:String)->void:
	s_cache_texts.erase(v);var s:String=load_text(v)
	if !s.is_empty():s_cache_texts[k]=s;s_cache_texts.erase(v)

static func override_table(k:String,v:String)->void:
	s_cache_tables.erase(v);var t:Array[PackedStringArray]=load_table(v)
	if !t.is_empty():s_cache_tables[k]=t;s_cache_tables.erase(v)

static func init()->void:
	if s_is_inited:return
	s_is_inited=true
	#
	s_file_api=Application.get_plugin(&"FilePlugin",true)
	if s_file_api.is_empty():
		s_file_api.exists=LangExtension.k_empty_callable
		s_file_api.open=FileAccess.open
		s_file_api.text=LangExtension.k_empty_callable
		s_file_api.table=LangExtension.k_empty_callable

static func exist_asset(f:String)->bool:
	if !s_is_inited:init()
	var m:Callable=s_file_api.exists
	if !m.is_null():return m.call(f)
	return FileAccess.file_exists(f)

static func load_text(f:String)->String:
	if !s_is_inited:init()
	if s_cache_texts.has(f):return s_cache_texts[f]
	#
	var m:Callable=s_file_api.text;if !m.is_null():
		var s:String=m.call(f)
		if !s.is_empty():
			s_cache_texts.set(f,s);return s
	#
	if exist_asset(f):
		var a:FileAccess=s_file_api.open.call(f,FileAccess.READ)
		if a!=null:
			var s:String=a.get_as_text()
			s_cache_texts.set(f,s);return s
	return LangExtension.k_empty_string

static func load_table(f:String,d:String=",")->Array[PackedStringArray]:
	if !s_is_inited:init()
	if s_cache_tables.has(f):return s_cache_tables[f]
	#
	var m:Callable=s_file_api.table;if !m.is_null():
		var t:Array[PackedStringArray]=m.call(f)
		if !t.is_empty():
			s_cache_tables.set(f,t);return t
	#
	if exist_asset(f):
		var a:FileAccess=s_file_api.open.call(f,FileAccess.READ)
		if a!=null:
			var it=a.get_csv_line(d);var n:int=it.size()
			var t:Array[PackedStringArray];t.append(it)
			while !a.eof_reached():
				it=a.get_csv_line(d)
				if it.size()>=n:t.append(it)
			s_cache_tables.set(f,t);return t
	return LangExtension.k_empty_table
