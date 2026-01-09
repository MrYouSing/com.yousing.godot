/* <!-- Macro.Define bFixPatch=
true
 Macro.End --> */

// =B$1&"_"&$A2&","
/* <!-- Macro.Table LayoutPreset
TOP_LEFT,
CENTER_TOP,
TOP_RIGHT,
TOP_WIDE,
CENTER_LEFT,
CENTER,
CENTER_RIGHT,
HCENTER_WIDE,
BOTTOM_LEFT,
CENTER_BOTTOM,
BOTTOM_RIGHT,
BOTTOM_WIDE,
LEFT_WIDE,
VCENTER_WIDE,
RIGHT_WIDE,
FULL_RECT,
 Macro.End --> */
/* <!-- Macro.Copy
const k_layout_presets:Dictionary[Control.LayoutPreset,int]={
 Macro.End --> */
/* <!-- Macro.Call  LayoutPreset
Control.LayoutPreset.PRESET_{0}:$(Table.Row),
 Macro.End --> */
/* <!-- Macro.Copy
}

@export_group("Transform")
 Macro.End --> */

/* <!-- Macro.Table Field
Control,control,,DIRTY,,
bool,unity,=true,DIRTY,## Use the unity-style coordinate system?,
Vector2,anchored_position,,DIRTY,,
Vector2,size_delta,ONE*100.0,DIRTY,,,,
$PRESET,anchor_preset,=-1,;if x>=0:_on_preset(x&#44;-1),,
Vector2,anchor_min,HALF,DIRTY,,
Vector2,anchor_max,HALF,DIRTY
$PRESET,pivot_preset,=-1,;if x>=0:_on_preset(-1&#44;x),,
Vector2,pivot,HALF,DIRTY,,
 Macro.End --> */
/* <!-- Macro.Call  Field
@export var {1}:{0}{2}:{4}
	set(x):{1}=x{3}
 Macro.End --> */
/* <!-- Macro.Replace
$PRESET,Control.LayoutPreset
ONE,=Vector2.ONE
HALF,=MathExtension.k_vec2_half
DIRTY,;_on_dirty()
\r\n,\n
 Macro.End --> */

/* <!-- Macro.Patch
ui_transform.gd,AutoGen
 Macro.End --> */

/* <!-- Macro.Copy
const k_transform_presets:Dictionary[StringName,int]={
 Macro.End --> */
/* <!-- Macro.Call  LayoutPreset
&"PRESET_{0}":$(Table.Row),
 Macro.End --> */
/* <!-- Macro.Copy
}
 Macro.End --> */
/* <!-- Macro.Replace
\r\n,\n
 Macro.End --> */
/* <!-- Macro.Patch
ui_layout.gd,AutoGen
 Macro.End --> */