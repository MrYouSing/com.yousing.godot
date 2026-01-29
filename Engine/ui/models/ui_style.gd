## A [url=https://developer.mozilla.org/zh-CN/docs/Web/HTML/Reference/Elements/style]style[/url] description for ui display and layout.
class_name UIStyle extends Resource

@export_group("Layout","layout_")
@export var layout_mask:Vector2i=Vector2i.ONE
@export var layout_jump:Vector4=Vector4(0.5,0.5,NAN,NAN)
@export var layout_padding:Vector4
@export var layout_cell:Vector2
@export var layout_spacing:Vector2

var _theme:Theme

func get_theme(c:Control)->Theme:
	if c!=null:
		var t:Theme=c.theme
		if t==null:
			if _theme==null:_theme=Theme.new()
			t=_theme;c.theme=t
		elif _theme==null:
			_theme=t
		return t
	return null

func layout_index(p:Vector2)->Vector2i:
	p-=Vector2(layout_padding.x,layout_padding.y)
	p+=layout_spacing# Add spacing to next when disappear.
	return p/(layout_cell+layout_spacing)

func layout_point(i:Vector2i)->Vector2:
	var b:Vector2=i
	var p:Vector2=Vector2(layout_padding.x,layout_padding.y)
	return p+(layout_cell+layout_spacing)*b

func layout_local(p:Vector2)->Vector2:
	if p.x>=0.0:p.x/=layout_cell.x
	else:p.x/=layout_spacing.x
	if p.y>=0.0:p.y/=layout_cell.y
	else:p.y/=layout_spacing.y
	layout_jump.z=layout_spacing.x/layout_cell.x
	layout_jump.w=layout_spacing.y/layout_cell.y
	return p

func layout_size(c:Vector2i)->Vector2:
	var b:Vector2=c
	var d:Vector2=b-Vector2.ONE
	var p:Vector2=Vector2(layout_padding.x+layout_padding.z,layout_padding.y+layout_padding.w)
	return p+layout_cell*b+layout_spacing*d

func layout_apply(o:Object)->void:
	if o==null:return
	if o is Container:
		var k:StringName=o.get_class()
		var t:Theme=get_theme(o)
		match k:
			&"GridContainer":
				t.set_constant(&"h_separation",k,layout_spacing.x)
				t.set_constant(&"v_separation",k,layout_spacing.y)
			_:
				var v:Vector2=layout_mask;v*=layout_spacing
				t.set_constant(&"separation",k,v.x+v.y)
	elif o is Control:
		o.custom_minimum_size=layout_cell
