## A view class that shows models in a grid.
class_name GridView extends CollectionView

@export_group("Grid")
@export var count:Vector2i:
	set(x):count=x;capacity=count.x*count.y
@export var loop_x:LoopMode
@export var loop_y:LoopMode
@export var page:int
@export var cache:Vector4i:
	set(x):cache=x;_start=-1;render()

func is_sequence(m:LoopMode,i:int,b:int)->bool:
	if m&0x0100!=0 and i!=0:
		if get_loop(1,0,maxi(m&0xFF,LoopMode.Loop),b):return true
	return false

func focus(i:int)->void:
	if _start>=0:
		if cache.length_squared()==0:
			index.x=MathExtension.int_repeat(_start+i,num_models())
		else:
			var w:int=count.x;var h:int=ceili(num_models()/float(w))
			var l:int=cache.x+w+cache.z
			var x:int=i%l-cache.x;var y:int=i/l-cache.y
			x+=_start%w;y+=_start/w
			x=MathExtension.int_repeat(x,w)
			y=MathExtension.int_repeat(y,h)
			index.x=w*y+x
	super.focus(i)

func clear()->void:
	super.clear()
	_start=-1

func render()->void:
	var s:int=index.y;var z:bool=cache.length_squared()==0
	# Draw
	if s!=_start:
		var n:int=num_models();if n<=0:return
		var w:int=count.x;var h:int=ceili(n/float(w))
		var i:int=-1;if z:
			h=mini(h,count.y)
			for y in h:for x in w:
				i+=1;if s+i>=n:draw_view(i,-1)
				else:draw_view(i,s+y*w+x)
		else:
			var l:int=cache.x;var r:int=cache.z
			var t:int=cache.y;var b:int=cache.w
			var p:int=s%w;var q:int=s/w
			var u:int;var v:int
			r=l+w+r;b=t+count.y+b
			for y in b:for x in r:
				i+=1
				u=MathExtension.int_repeat(p+x-l,w)
				v=MathExtension.int_repeat(q+y-t,h)
				if u>=n-w*v:draw_view(i,-1)
				else:draw_view(i,w*v+u)
		i+=1;for j in _views.size()-i:draw_view(i+j,-1)
	# Select
	_start=-1
	if z:
		focus(index.x-s)
	else:
		var w:int=count.x;var x:int=index.x-s
		var y:int=x/count.y;x=x%w
		w=cache.x+w+cache.z
		focus(w*(cache.y+y)+cache.x+x)
	_start=s

func listen()->void:
	var v:Vector3i=Vector3i.ZERO;var b:int=-1;var i:int
	if page>0:
		i=4;if b<0 and is_input(i):b=i;v.z=-page
		i=5;if b<0 and is_input(i):b=i;v.z= page
	i=0;if b<0 and is_input(i):b=i;v.x=-1
	i=1;if b<0 and is_input(i):b=i;v.x= 1
	i=2;if b<0 and is_input(i):b=i;v.y=-1
	i=3;if b<0 and is_input(i):b=i;v.y= 1
	if b>=0:
		var n:int=num_models()
		var w:int=count.x;var h:int=ceili(n/float(w))
		var a:int=index.x
		var x:int=a%w+v.x;var y:int=a/w+v.y
		a=-1;if a==-1 and is_sequence(loop_y,v.y,b):
			if y<0:a=n-1
			elif y>=h:a=0
		if a==-1 and is_sequence(loop_x,v.x,b):
			if x<0:x=w-1;y=MathExtension.int_repeat(y-1,h);a=-2
			elif x>=w:x=0;y=MathExtension.int_repeat(y+1,h);a=-2
		if a==-1:
			y=wrap_index(y,h,get_loop(y,h,loop_y))
			a=mini(n-w*y,w)
			x=wrap_index(x,a,get_loop(x,a,loop_x))
			a=-1
		#
		if a>=0:index.x=a
		else:index.x=wrap_index(w*y+x+v.z,n,false);
		a=index.y/w;index.y=move_index(y,a,a+count.y-1)*w
		render()
	for c in inputs-6:if is_input(6+c):execute(c)
