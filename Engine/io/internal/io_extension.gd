## An extension class for IO.
class_name IOExtension

static var s_sandboxes:PackedStringArray=["res://","user://"]

# String APIs

static func check_path(x:String)->String:
	if x.find("\\")>=0:x=x.replace("\\","/")
	return x

static func file_name(x:String)->String:
	var i:int=x.rfind("/")
	if i>=0:x=x.substr(i+1)
	return x

static func file_name_only(x:String)->String:
	var i:int=x.rfind("/")
	var j:int=x.rfind(".")
	if i>=0:
		if j>=0 and i<j:x=x.substr(i+1,j-i-1)
		else:x=x.substr(i+1)
	return x

static func file_extension(x:String)->String:
	var i:int=x.rfind("/")
	var j:int=x.rfind(".")
	if j>=0 and i<j:return x.substr(j).to_lower()
	return LangExtension.k_empty_string

static func file_variant(x:String,a:PackedStringArray)->String:
	if x.is_empty():return x
	var t:String=file_extension(x)
	var n:int=t.length();if n>0:
		if a.has(t) and FileAccess.file_exists(t):return t
		else:x=x.substr(0,x.length()-n)
	for it in a:t=x+it;if FileAccess.file_exists(t):return t
	return LangExtension.k_empty_string

static func directory_name(x:String)->String:
	var i:int=x.rfind("/")
	if i>=0:x=x.substr(0,i)
	return x

static func combine_path(a:String,b:String)->String:
	var x:bool=a.ends_with("/");var y:bool=b.ends_with("/")
	if x and y:a+b.substr(1)
	elif x or y:return a+b
	return a+"/"+b

# File APIs

static func create_directory(d:String)->DirAccess:
	var a:DirAccess=DirAccess.open(d)
	if a==null:
		# 
		if d.ends_with("/"):d.remove_char(d.length()-1)
		a=create_directory(directory_name(d)+"/")
		#
		a.make_dir(file_name(d));a.change_dir(d)
	return a

static func copy_file(s:String,d:String,w:bool=false)->void:
	if FileAccess.file_exists(s):
		if not w and FileAccess.file_exists(d):return
		#
		create_directory(directory_name(d))
		var a:FileAccess=FileAccess.open(d,FileAccess.WRITE)
		a.store_buffer(FileAccess.get_file_as_bytes(s));a.close()

static func get_config(f:String,k:PackedStringArray)->void:
	if FileAccess.file_exists(f):
		var c:ConfigFile=ConfigFile.new();c.load(f);var s:String
		for i in c.get_sections():for j in c.get_section_keys(i):
			s=i+"/"+j;if not k.has(s):k.append(s)

static func set_config(f:String,k:PackedStringArray,v:bool)->void:
	if FileAccess.file_exists(f):
		var c:ConfigFile=ConfigFile.new();c.load(f)
		for i in c.get_sections():for j in c.get_section_keys(i):
			if k.has(i+"/"+j)!=v:c.set_value(i,j,null)
		c.save(f)

static func save_json(j:Variant,f:String,t:String="\t")->void:
	var a:FileAccess=FileAccess.open(f,FileAccess.WRITE)
	a.store_string(JSON.stringify(j,t,false))
	a.close()

static func load_json(f:String)->Variant:
	if FileAccess.file_exists(f):
		var a:FileAccess=FileAccess.open(f,FileAccess.READ)
		var j:Variant=JSON.parse_string(a.get_as_text())
		a.close();return j
	return null

# Resource APIs

static func is_sandbox(f:String)->bool:
	#if s_sandboxes.size()>2:f=f.to_lower()
	for it in s_sandboxes:if f.begins_with(it):return true
	return false

static func load_asset(f:String,t:String=LangExtension.k_empty_string)->Resource:
	if not is_sandbox(f):f=s_sandboxes[0]+f
	if FileAccess.file_exists(f):return ResourceLoader.load(f,t)
	return null

static func import_asset(f:String,t:String=LangExtension.k_empty_string)->Resource:
	if FileAccess.file_exists(f):
		if not is_sandbox(f):
			var d:String=combine_path(s_sandboxes[0]+"/imported",file_name(f))
			copy_file(f,d,true);f=d;ClassDB.class_call_static(&"EditorInterface",&"get_resource_filesystem").scan()
		return ResourceLoader.load(f,t)
	return null
