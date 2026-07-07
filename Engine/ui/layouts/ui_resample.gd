## A helper class for [Control] resampling.
class_name UIResample extends Runnable

static var s_labels:Dictionary[String,LabelSettings]

@export_group("Re-Sample")
@export var control:Control
@export var resolution:float=1.0
@export var reference:UITransform
@export var shared:bool
@export var fonts:PackedStringArray=[
	"font_size",
	"mono_font_size",
	"normal_font_size",
	"bold_font_size",
	"italics_font_size",
	"bold_italics_font_size",
]
@export var sizes:PackedStringArray=[
	"line_spacing",
	"paragraph_spacing",
	"outline_size",
	"shadow_outline_size",
	"shadow_offset_x",
	"shadow_offset_y",
]

var _label:LabelSettings

func run()->void:
	if control==null:return
	sample(control,resolution,1.0/resolution)

func sample(o:Object,r:float,f:float)->void:
	if o==null:
		pass
	elif typeof(o.get(&"text"))!=TYPE_NIL:
		for it in fonts:UIExtension.scale_theme_font_size(o,it,r)
		for it in sizes:UIExtension.scale_theme_constant(o,it,r)
		var s:LabelSettings=o.get(&"label_settings") as LabelSettings
		if s!=null:
			# Alloc
			if _label==null:
				if shared:
					var p:String=s.resource_name+str(resolution)
					_label=IOExtension.vary_asset(s_labels,p,s)
				else:
					_label=s.duplicate()
				o.label_settings=_label
			UIExtension.scale_label_settings(_label,s,r)
		o.scale=Vector2(f,f);f=r
	else:
		o.scale=Vector2(r,r)
	UIExtension.resample_transform(reference,o,f)

func _ready()->void:
	if control==null:control=GodotExtension.assign_node(self,"Control")
	super._ready()
