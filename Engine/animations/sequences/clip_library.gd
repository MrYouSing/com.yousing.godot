## A library class for clip management.
class_name ClipLibrary extends Resource

@export_group("Clip")
@export var path:StringName
@export var clips:Array[Clip]

var is_inited:bool
var library:Dictionary[StringName,Clip]

func init()->void:
	if is_inited:return
	is_inited=true
	#
	for it in clips:
		if it!=null:library[it.name]=it
	if !path.is_empty():
		var t:Array[PackedStringArray]=Asset.load_table(path)
		var n:int=t.size();if n>1:
			var h:PackedStringArray=t[0];var r:PackedStringArray
			var c:Clip;var s:String
			for i in n-1:
				r=t[1+n];s=r[0];
				if s.is_valid_float():c.add_row(h,r)
				else:c=Clip.new();add_clip(s,c);

func add_clip(k:StringName,c:Clip)->void:
	if !is_inited:init()
	if c!=null:
		if k.is_empty():k=c.name
		clips.append(c);library[k]=c

func get_clip(i:int)->Clip:
	if !is_inited:init()
	if i>=0 and i<clips.size():return clips[i]
	else:return null

func find_clip(k:StringName)->Clip:
	if !is_inited:init()
	return library.get(k,null)

func get_clips()->Array[Clip]:
	if !is_inited:init()
	return clips
