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
	var i:int=x.rfind(".")
	if i>=0:return x.substr(i).to_lower()
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

static func get_config(f:String,k:PackedStringArray)->void:
	if FileAccess.file_exists(f):
		var c:ConfigFile=ConfigFile.new();c.load(f);var s:String
		for i in c.get_sections():for j in c.get_section_keys(i):
			s=i+"/"+j;if !k.has(s):k.append(s)

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

static func load_asset(f:String)->Resource:
	if !is_sandbox(f):f=s_sandboxes[0]+f
	if FileAccess.file_exists(f):return ResourceLoader.load(f)
	return null
