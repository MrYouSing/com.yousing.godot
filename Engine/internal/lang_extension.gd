class_name LangExtension

const k_empty_string:String=""
const k_empty_array:Array=[]
const k_empty_dictionary:Dictionary={}
const k_empty_callable:Callable=Callable()
const k_empty_signal:Signal=Signal()

static var s_none_string:String="None"

# https://learn.microsoft.com/zh-cn/dotnet/api/system.notimplementedexception
static var e_not_implemented:Dictionary={
	"text":"Not Implemented Exception"
}

static func throw_exception(c:Object,e:Dictionary)->void:
	push_error(e["text"])

# String APIs

static func file_name(x:String)->String:
	var i:int=x.rfind("/")
	if i>=0:x=x.substr(i+1)
	return x

static func directory_name(x:String)->String:
	var i:int=x.rfind("/")
	if i>=0:x=x.substr(0,i)
	return x

static func combine_path(a:String,b:String)->String:
	var x:bool=a.ends_with("/");var y:bool=b.ends_with("/")
	if x and y:a+b.substr(1)
	elif x or y:return a+b
	return a+"/"+b

# Collection APIs

static func get_item(a:Array,i:int,v:Variant)->Variant:
	if i>=0 and i<a.size():return a[i]
	return v

static func set_item(a:Array,i:int,v:Variant)->void:
	if i>=a.size():a.append(v)
	else:a[i]=v

static func remove_range(a:Array,o:int,c:int=-1)->void:
	var e:int=a.size()-o;if c<0 or c>e:c=e
	e=e-c;if e>0:# Move next slice.
		for i in e:a[o]=a[o+c];o+=1
	o=o+c-1
	for i in c:a.remove_at(o-i)

# Event/Signal APIs

static func clear_signal(s:Signal)->void:
	if !s.is_null() and s.has_connections():
		for it in s.get_connections():
			s.disconnect(it.callable)

static func bake_signal(c:Object,k:StringName,t:Array,m:Array[StringName])->Signal:
	if !c.has_user_signal(k):c.add_user_signal(k)
	var tmp:Signal=Signal(c,k);var j:int=m.size()
	var i:int=-1;for it in t:
		i+=1;if i<j:k=m[i]
		if it!=null and it.has_method(k):
			var d=Callable(it,k)
			if !tmp.is_connected(d):tmp.connect(d)
	return tmp

static func merge_signal(c:Object,s:Signal,r:Signal,a:Array,m:StringName,f:int=0)->Signal:
	if s.is_null():
		if !c.has_user_signal(m):c.add_user_signal(m)
		s=Signal(c,m)
	else:
		clear_signal(s)
	#
	if !r.is_null() and r.has_connections():# From Engine
		for it in r.get_connections():
			s.connect(it.callable,it.flags)
	if !a.is_empty() and !m.is_empty():# From User
		for it in a:
			if it!=null and it.has_method(m):
				var d:Callable=Callable(it,m)
				if !s.is_connected(d):s.connect(d,f)
	return s
