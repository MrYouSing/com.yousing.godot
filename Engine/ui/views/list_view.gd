## A view class that shows models in a list.
class_name ListView extends CollectionView

@export_group("List")
@export var loop:LoopMode
@export var page:int
@export var cache:Vector2i:
	set(x):cache=x;_start=-1;render()

func focus(i:int)->void:
	if _start>=0:index.x=MathExtension.int_repeat(_start+i-cache.x,num_models())
	super.focus(i)

func clear()->void:
	super.clear()
	_start=-1

func render()->void:
	var s:int=index.y
	if s!=_start:
		var n:int=num_models();if n<=0:return
		var c:int=mini(n,capacity)
		#
		var j:int=cache.x
		for i in j:draw_view(i,(s-j+i+n)%n)
		for i in c:draw_view(j+i,s+i)
		j+=c;c+=s
		for i in cache.y:draw_view(j+i,(c+i)%n)
	_start=-1
	focus(cache.x+index.x-s)
	_start=s

func listen()->void:
	var a:int=0;var b:int=-1;var i:int
	if page>0:
		i=2;if b<0 and is_input(i):b=i;a=-page
		i=3;if b<0 and is_input(i):b=i;a= page
	i=0;if b<0 and is_input(i):b=i;a=-1
	i=1;if b<0 and is_input(i):b=i;a= 1
	if b>=0:
		var n:int=num_models()
		a=index.x+a;index.x=wrap_index(a,n,get_loop(a,n,loop,b))
		a=index.y;index.y=move_index(index.x,a,a+capacity-1)
		render()
	for c in inputs-4:if is_input(4+c):execute(c)
