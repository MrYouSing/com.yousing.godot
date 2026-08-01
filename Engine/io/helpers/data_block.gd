## A resource used to store chained data.
class_name DataBlock extends Resource

static func load_table(s:Variant,t:Array[PackedStringArray],d:Dictionary)->void:
	if s==null:return
	var n:int=t.size()
	if n<=0:return
	#
	var o:DataBlock=null
	var h:PackedStringArray=t[0];var k:StringName
	var r:PackedStringArray;var m:int;var v:String
	n-=1;for i in n:
		r=t[1+i];m=r.size();if m<2:continue
		o=s.new()
		k=r[0];o.resource_name=k;d[k]=o
		k=r[1];if not k.is_empty():o.parent=d.get(k,null)
		#
		m-=2;for j in m:
			v=r[2+i];if v.is_empty():continue
			o.set(h[2+i],v)

static func load_file(s:Variant,a:Array,p:String,d:Dictionary)->void:
	if p.is_empty():return
	var t:Array[PackedStringArray]=Asset.load_table(p)
	for it in a:if it!=null:d[it.resource_name]=it
	load_table(s,t,d)

@export_group("Data")
@export var parent:DataBlock

var _mask:int

func _block_override(i:int)->bool:
	return _mask&(1<<i)!=0

func _block_dirty(i:int)->void:
	_mask|=(1<<i)

func _block_reset(i:int)->void:
	_mask&=~(1<<i)

func _block_eval(i:int,k:StringName,v:Variant)->Variant:
	return null

func _block_get(i:int,k:StringName,v:Variant)->Variant:
	if not _block_override(i):
		var t:Variant=_block_eval(i,k,v);if t!=null:return t
		if parent!=null:return parent.get(k)
	return v
