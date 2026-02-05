class_name LangExtension

const k_empty_string:String=""
const k_empty_name:StringName=&""
const k_empty_rid:RID=RID()
const k_empty_array:Array=[]
const k_empty_dictionary:Dictionary={}
const k_empty_table:Array[PackedStringArray]=[]
const k_empty_callable:Callable=Callable()
const k_empty_signal:Signal=Signal()

static var s_none_string:String="None"
static var s_temp_array:Array=[]
static var s_lock_busy:Array[Object]

# https://learn.microsoft.com/zh-cn/dotnet/api/system.notimplementedexception
static var e_not_implemented:Dictionary={
	"text":"Not Implemented Exception"
}

static func throw_exception(o:Object,e:Dictionary)->void:
	var t:String=e["text"]
	push_error(t)
	printerr(t)
	print_stack()

# Reflection APIs

static func class_of(o:Object,a:PackedStringArray,b:Array[Resource])->int:
	if o!=null:
		var i:int=b.find(o.get_script());if i>=0:return a.size()+i
		i=a.find(o.get_class());if i>=0:return i
	return -1

static func class_is(o:Object,c:Variant,t:int=-1)->bool:
	if o!=null:
		if t<0:typeof(c)
		match t:
			TYPE_STRING,TYPE_STRING_NAME:
				var a:StringName=o.get_class()
				var b:StringName=c
				return a==b or ClassDB.is_parent_class(a,b)
			TYPE_OBJECT:
				var a:Script=o.get_script()
				var b:Object=c
				while a!=null:
					if a==b:return true
					a=a.get_base_script()
			TYPE_ARRAY,TYPE_PACKED_STRING_ARRAY:
				for it in c:if !o.has_method(it):return false
				return true
	return false

static func class_has(c:Variant,m:StringName,k:StringName,b:bool=false)->bool:
	var d:Array=k_empty_array;match typeof(c):
		TYPE_STRING,TYPE_STRING_NAME:
			if ClassDB.class_exists(c):d=ClassDB.call(&"class_get_%s_list"%m,c,!b)
		TYPE_OBJECT:
			if c is Script:d=c.call(&"get_script_%s_list"%m)
			else:d=c.call(&"get_%s_list"%m)
	for it in d:if it.name==k:return true
	return false

static func class_cast(o:Object,c:Variant)->Object:
	match typeof(c):
		TYPE_STRING,TYPE_STRING_NAME:
			var b:StringName=c
			if o==null or !class_is(o,b,TYPE_STRING_NAME):
				if ClassDB.class_exists(b):return ClassDB.instantiate(b)
				else:return null
		TYPE_OBJECT:
			var b:Resource=c
			if o==null or !class_is(o,b,TYPE_OBJECT):
				return b.new()
		_:return null
	return o

static func str_to_enum(s:String,c:Variant)->int:
	if !s.is_empty() and !c.is_empty():match typeof(c):
		TYPE_DICTIONARY:
			return c.get(s,-1)
		TYPE_ARRAY,TYPE_PACKED_STRING_ARRAY:
			return c.find(s)
	return -1

static func str_to_mask(s:String,c:Variant,d:String="|")->int:
	var m:int=0;if !s.is_empty() and !c.is_empty():match typeof(c):
		TYPE_DICTIONARY:
			var t:Dictionary=c
			var i:int;for it in s.split(d,false):i=t.get(it,-1);if i>=0:m|=i
		TYPE_ARRAY,TYPE_PACKED_STRING_ARRAY:
			var i:int;for it in s.split(d,false):i=c.find(it);if i>=0:m|=(1<<i)
	return m

static func str_to_args(s:String,d:String=",")->Array:
	if !s.is_empty():
		var p:PackedStringArray=s.split(d);var i:int=p.size()
		if i>0:
			var a:Array;a.resize(i)
			i=-1;for it in p:i+=1;a[i]=str_to_var(it)
			return a
	return k_empty_array

static func enum_to_str(e:int,c:Variant)->String:
	if !c.is_empty():
		match typeof(c):
			TYPE_DICTIONARY:
				var k:Variant=c.find_key(e);if k!=null:return k
			TYPE_ARRAY,TYPE_PACKED_STRING_ARRAY:
				return c[e]
	return k_empty_string

static func mask_to_str(m:int,c:Variant,d:String="|")->String:
	if !c.is_empty():
		var p:PackedStringArray;var j:int;var k:Variant
		match typeof(c):
			TYPE_DICTIONARY:
				var t:Dictionary=c
				for i in 32:j=1<<i;if m&j!=0:k=t.find_key(j);if k!=null:p.append(k)
			TYPE_ARRAY,TYPE_PACKED_STRING_ARRAY:
				for i in c.size():j=1<<i;if m&j!=0:k=c[i];if k!=null:p.append(k)
		return d.join(p)
	return k_empty_string

# String APIs

# Collection APIs

## New an array with new instances.
static func new_array(c:Script,n:int)->Array:
	if c==null:
		var a:Array=Array()
		if n>0:a.resize(n)
		return a
	else:
		var a:Array=Array(k_empty_array,TYPE_OBJECT,c.get_instance_base_type(),c)
		if n>0:a.resize(n);for i in n:a[i]=c.new()
		return a

## Allocate an array without values.
static func alloc_array(c:Variant,n:int)->Array:
	if c==null:
		var a:Array=Array()
		if n>0:a.resize(n)
		return a
	else:
		var a:Array=k_empty_array
		match typeof(c):
			TYPE_INT:a=Array(a,c,k_empty_name,null)
			TYPE_STRING_NAME:a=Array(a,TYPE_OBJECT,c,null)
			TYPE_OBJECT:a=Array(a,TYPE_OBJECT,c.get_instance_base_type(),c)
			_:a=Array()
		if n>0:a.resize(n)
		return a

static func get_item(a:Array,i:int,v:Variant)->Variant:
	if i>=0 and i<a.size():return a[i]
	return v

static func set_item(a:Array,i:int,v:Variant)->void:
	if i>=a.size():a.append(v)
	else:a[i]=v

static func move_item(a:Array,i:int,j:int)->void:
	if j<0:j+=a.size()
	var v:Variant=a[i];a.remove_at(i);a.insert(j,v)

static func remove_range(a:Array,o:int,c:int=-1)->void:
	var e:int=a.size()-o;if c<0 or c>e:c=e
	e=e-c;if e>0:# Move next slice.
		for i in e:a[o]=a[o+c];o+=1
	o=o+c-1
	for i in c:a.remove_at(o-i)

static func merge_array(a:Array,b:Array)->void:
	for it in b:if !a.has(it):a.append(it)

static func merge_strings(a:PackedStringArray,b:PackedStringArray)->void:
	for it in b:if !a.has(it):a.append(it)

static func remove_array(a:Array,b:Array)->void:
	var n:int=a.size();var j:int=0
	for it in a:if !b.has(it):a[j]=it;j+=1
	if j!=n:a.resize(j)

static func remove_strings(a:PackedStringArray,b:PackedStringArray)->void:
	var n:int=a.size();var j:int=0
	for it in a:if !b.has(it):a[j]=it;j+=1
	if j!=n:a.resize(j)

static func map_to_object(m:Dictionary,o:Object)->void:
	if m.is_empty() or o==null:return
	for k in m:o.set(k,m[k])

static func row_to_object(h:PackedStringArray,r:PackedStringArray,o:Object)->void:
	if r.is_empty() or o==null:return
	var i:int=-1;for it in h:i+=1;o.set(it,r[i])

static func maps_to_array(m:Array,c:Script)->Array:
	var n:int=m.size();if n<=0:return k_empty_array
	if c==null:return m
	#
	var a:Array=new_array(c,n)
	for i in n:map_to_object(m[i],a[i])
	return a

static func table_to_array(t:Array[PackedStringArray],c:Script)->Array:
	var n:int=t.size();if n<=1:return k_empty_array
	if c==null:return t
	#
	n-=1;var h:PackedStringArray=t[0]
	var a:Array=new_array(c,n)
	for i in n:row_to_object(h,t[1+i],a[i])
	return a

static func array_add_maps(a:Array,m:Array,c:Script)->void:
	var n:int=m.size();if n<=0:return
	#
	var o:Object;var s:int=a.size();a.resize(s+n)
	for i in n:o=c.new();map_to_object(m[i],o);a[s+i]=o

static func array_add_table(a:Array,t:Array[PackedStringArray],c:Script)->void:
	var n:int=t.size();if n<=1:return
	#
	n-=1;var h:PackedStringArray=t[0]
	var o:Object;var s:int=a.size();a.resize(s+n)
	for i in n:o=c.new();row_to_object(h,t[1+i],o);a[s+i]=o

# Event/Signal APIs

	# Busy Lock

static func is_busy(o:Object)->bool:
	if o==null:return !s_lock_busy.is_empty()
	return s_lock_busy.has(o)

static func not_busy(o:Object)->bool:
	if o==null:return s_lock_busy.is_empty()
	return !s_lock_busy.has(o)

static func begin_busy(o:Object)->void:
	if o==null:return
	s_lock_busy.append(o)

static func end_busy(o:Object)->void:
	if o==null:return
	var i:int=s_lock_busy.rfind(o)
	if i>=0:s_lock_busy.remove_at(i)

	# Signal APIs

static func clear_signal(s:Signal)->void:
	if !s.is_null() and s.has_connections():
		for it in s.get_connections():
			s.disconnect(it.callable)

static func call_signal(s:Signal,a:Array)->void:
	if !s.is_null():match a.size():
		0:s.emit()
		1:s.emit(a[0])
		2:s.emit(a[0],a[1])
		3:s.emit(a[0],a[1],a[2])
		4:s.emit(a[0],a[1],a[2],a[3])
		5:s.emit(a[0],a[1],a[2],a[3],a[4])
		6:s.emit(a[0],a[1],a[2],a[3],a[4],a[5])
		7:s.emit(a[0],a[1],a[2],a[3],a[4],a[5],a[6])
		8:s.emit(a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7])

static func shoot_signal(s:Signal,o:Object,a:Array)->void:
	if !s.is_null() and o!=null:
		var t:Array[Callable];var c:Callable
		for it in s.get_connections():
			c=it.callable;if c.get_object()==o:t.append(c)
		for it in t:it.callv(a);s.disconnect(it)

	# Object APIs

static func free_signal(o:Object,k:StringName)->void:
	if o==null or k.is_empty():return
	var b:bool=o.has_user_signal(k)
	if !o.has_signal(k) and !b:return
	for it in o.get_signal_connection_list(k):
		o.disconnect(k,it.callable)
	if b:o.remove_user_signal(k)

static func new_signal(o:Object,k:StringName)->Signal:
	if o==null or k.is_empty():return k_empty_signal
	if !o.has_signal(k) and !o.has_user_signal(k):o.add_user_signal(k)
	return Signal(o,k)

static func exist_signal(o:Object,k:StringName)->bool:
	if o==null:return false
	return o.has_signal(k) or o.has_user_signal(k)

static func info_signal(o:Object,k:StringName)->Dictionary:
	if o!=null and !k.is_empty():
		var a:Array[Dictionary]=o.get_signal_list()
		for it in a:if it.name==k:return it
	return k_empty_dictionary

static func add_signal(o:Object,k:StringName,v:Callable,f:int=0)->void:
	if o==null or v.is_null():return
	if !o.has_signal(k) and !o.has_user_signal(k):o.add_user_signal(k)
	if !o.is_connected(k,v):o.connect(k,v,f)

static func try_signal(o:Object,k:StringName,v:Callable,f:int=0)->void:
	if o==null or v.is_null():return
	if !o.has_signal(k) and !o.has_user_signal(k):return
	if !o.is_connected(k,v):o.connect(k,v,f)

static func remove_signal(o:Object,k:StringName,v:Callable)->void:
	if o==null or v.is_null():return
	if !o.has_signal(k) and !o.has_user_signal(k):return
	if o.is_connected(k,v):o.disconnect(k,v)

static func send_signal(o:Object,k:StringName,a:Array)->void:
	if o!=null and !k.is_empty():match a.size():
		0:o.emit_signal(k)
		1:o.emit_signal(k,a[0])
		2:o.emit_signal(k,a[0],a[1])
		3:o.emit_signal(k,a[0],a[1],a[2])
		4:o.emit_signal(k,a[0],a[1],a[2],a[3])
		5:o.emit_signal(k,a[0],a[1],a[2],a[3],a[4])
		6:o.emit_signal(k,a[0],a[1],a[2],a[3],a[4],a[5])
		7:o.emit_signal(k,a[0],a[1],a[2],a[3],a[4],a[5],a[6])
		8:o.emit_signal(k,a[0],a[1],a[2],a[3],a[4],a[5],a[6],a[7])

	# Advanced APIs

static func bake_signal(o:Object,k:StringName,t:Array,m:Array[StringName])->Signal:
	if !o.has_user_signal(k):o.add_user_signal(k)
	var tmp:Signal=Signal(o,k);var j:int=m.size()
	var i:int=-1;for it in t:
		i+=1;if i<j:k=m[i]
		if it!=null and it.has_method(k):
			var d=Callable(it,k)
			if !tmp.is_connected(d):tmp.connect(d)
	return tmp

static func merge_signal(o:Object,s:Signal,r:Signal,a:Array,m:StringName,f:int=0)->Signal:
	if s.is_null():
		if !o.has_user_signal(m):o.add_user_signal(m)
		s=Signal(o,m)
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
