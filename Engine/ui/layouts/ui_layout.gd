## A layout manager for [Control].
class_name UILayout extends Node

const k_layout_presets:Dictionary[StringName,int]={
&"PRESET_TOP_LEFT":0,
&"PRESET_TOP_RIGHT":1,
&"PRESET_BOTTOM_LEFT":2,
&"PRESET_BOTTOM_RIGHT":3,
&"PRESET_CENTER_LEFT":4,
&"PRESET_CENTER_TOP":5,
&"PRESET_CENTER_RIGHT":6,
&"PRESET_CENTER_BOTTOM":7,
&"PRESET_CENTER":8,
&"PRESET_LEFT_WIDE":9,
&"PRESET_TOP_WIDE":10,
&"PRESET_RIGHT_WIDE":11,
&"PRESET_BOTTOM_WIDE":12,
&"PRESET_VCENTER_WIDE":13,
&"PRESET_HCENTER_WIDE":14,
&"PRESET_FULL_RECT":15,
}
# <!-- Macro.Patch AutoGen
const k_transform_presets:Dictionary[StringName,int]={
&"PRESET_TOP_LEFT":0,
&"PRESET_CENTER_TOP":1,
&"PRESET_TOP_RIGHT":2,
&"PRESET_TOP_WIDE":3,
&"PRESET_CENTER_LEFT":4,
&"PRESET_CENTER":5,
&"PRESET_CENTER_RIGHT":6,
&"PRESET_HCENTER_WIDE":7,
&"PRESET_BOTTOM_LEFT":8,
&"PRESET_CENTER_BOTTOM":9,
&"PRESET_BOTTOM_RIGHT":10,
&"PRESET_BOTTOM_WIDE":11,
&"PRESET_LEFT_WIDE":12,
&"PRESET_VCENTER_WIDE":13,
&"PRESET_RIGHT_WIDE":14,
&"PRESET_FULL_RECT":15,
}
# Macro.Patch -->
static func str_to_layout_preset(k:StringName)->int:
	return k_layout_presets.get(k,-1)

static func str_to_transform_preset(k:StringName)->int:
	return k_transform_presets.get(k,-1)

@export_group("Layout")
@export var layout:String
@export var views:Dictionary[StringName,Control]

var _rect:UITransform

func _ready()->void:
	_rect=GodotExtension.create(self,Control,UITransform)
	if not layout.is_empty():load_file(layout)

func set_layout(c:Control,p:Preset)->void:
	if c==null or p==null:return
	if p.anchor_max==-1:p.anchor_max=p.anchor
	#
	_rect.begin();_rect.control=c
	_rect.anchor(p.anchor,p.anchor_max,p.pivot)
	if _rect.anchor_min.is_equal_approx(_rect.anchor_max):
		_rect.rect(p.rect)
	else:
		_rect.padding(p.rect)
	_rect.end();_rect.control=null

func load_layout(l:Array)->void:
	var c:Control;for it in l:
		if it==null:continue
		c=views.get(it.name,null)
		if c==null:continue
		set_layout(c,it)

func load_file(f:String)->void:
	match IOExtension.file_extension(f):
		".json":
			var s:String=Asset.load_text(f)
			if s.is_empty():return
			else:load_layout(LangExtension.maps_to_array(JSON.parse_string(s),Preset))
		".csv":
			var t:Array[PackedStringArray]=Asset.load_table(f)
			if t.is_empty():return
			else:load_layout(LangExtension.table_to_array(t,Preset))
	layout=f

class Preset:
	var name:StringName
	var anchor:Control.LayoutPreset=-1
	var anchor_max:Control.LayoutPreset=-1
	var pivot:Control.LayoutPreset=-1
	var rect:Vector4

	func _set(k:StringName,v:Variant)->bool:
		if typeof(v)==TYPE_STRING:match k:
			&"$rect":
				rect=MathExtension.str_to_vec4(v as String,";")
				return true
			&"$anchor_min",&"$anchor":
				anchor=UILayout.str_to_transform_preset(v as StringName)
				return true
			&"$anchor_max":
				anchor_max=UILayout.str_to_transform_preset(v as StringName)
				return true
			&"$pivot":
				pivot=UILayout.str_to_transform_preset(v as StringName)
				return true
		return false
