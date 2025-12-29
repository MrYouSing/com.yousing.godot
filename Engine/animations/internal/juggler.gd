## A godot [url=https://doc.starling-framework.org/current/starling/animation/Juggler.html]Juggler[/url] implementation.
class_name Juggler extends Node

const k_keyword:StringName=&"YouSing_Juggler"
static var s_create:Callable=func()->Object:
	var i:Juggler=Juggler.new();i.name=k_keyword
	GodotExtension.add_node(i,null,false)
	i._ready();return i

static var instance:Juggler:
	get:return Singleton.try_instance(k_keyword,s_create)
	set(x):Singleton.set_instance(k_keyword,x)

static var current:Call=null

@export_group("Juggler")

var workers:Array[Worker]
var id:int=-1

func kill_call(i:int)->void:
	workers[(i>>30)&0x3].stop(i&0x3FFFFFFF)

func delay_call(c:Callable,a:Array,d:float=0.0,w:int=0)->int:
	var tmp:DelayedCall=DelayedCall.s_pool.obtain();
	tmp.delay=d;tmp.call=c;tmp.args.append_array(a)
	workers[w].start(tmp);return id|(w<<30)

func update_call(c:Callable,a:Array,d:float=0.0,l:float=-1.0,w:int=0)->int:
	var tmp:UpdatedCall=UpdatedCall.s_pool.obtain();
	tmp.delay=d;tmp.call=c;tmp.args.append_array(a)
	tmp.duration=l
	workers[w].start(tmp);return id|(w<<30)

func repeat_call(c:Callable,a:Array,d:float=0.0,t:float=1.0,n:int=-1,w:int=0)->int:
	var tmp:RepeatedCall=RepeatedCall.s_pool.obtain();
	tmp.delay=d;tmp.call=c;tmp.args.append_array(a)
	tmp.step=t;tmp.count=n
	workers[w].start(tmp);return id|(w<<30)

func _ready()->void:
	if Singleton.init_instance(k_keyword,self):
		for i in 4:workers.append(Juggler.Worker.new(self))

func _exit_tree()->void:
	if Singleton.exit_instance(k_keyword,self):
		pass

func _process(delta:float)->void:
	if workers.is_empty():return
	workers[0].update(delta)
	workers[1].update(delta/Engine.time_scale)

func _physics_process(delta:float)->void:
	if workers.is_empty():return
	workers[2].update(delta)
	workers[3].update(delta/Engine.time_scale)

class Worker:
	var context:Juggler
	var time:float
	var delta:float
	var calls:Array[Call]

	func _init(c:Juggler)->void:
		context=c

	func start(c:Call)->void:
		context.id+=1;if c.id>=0:
			printerr("Start Call@%04d again!"%c.id)
			return
		c.id=context.id;c.time=time
		c.worker=self;calls.append(c)

	func stop(c:int)->void:
		var i:int=-1;for it in calls:
			i+=1;if it!=null and it.id==c:
				calls[i]=null;it.recycle();return

	func update(d:float)->void:
		if is_zero_approx(d):return
		delta=d;time+=delta
		#
		var m:int=calls.size();if m==0:return
		var j:int=0;for it in calls:
			if it.update():calls[j]=it;j+=1
		LangExtension.remove_range(calls,j,m-j)

class Call:
	var worker:Worker
	var id:int=-1
	var time:float
	var delay:float
	var call:Callable
	var args:Array

	func progress()->float:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)
		return -1.0

	func update()->bool:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)
		return false

	func invoke()->void:
		var tmp:Call=Juggler.current;Juggler.current=self
		call.callv(args)
		Juggler.current=tmp

	func reset()->bool:
		if id<0:
			printerr("Reset Call@%04d again!"%(-id-1))# Read old id.
			return false
		else:
			worker=null;id=-id-1# Keep old id.
			time=-1.0;delay=-1.0
			call=LangExtension.k_empty_callable;args.clear()
			return true

	func recycle()->void:
		LangExtension.throw_exception(self,LangExtension.e_not_implemented)

class DelayedCall extends Call:
	static var s_pool:Collections.Pool=Collections.Pool.new(
		func()->DelayedCall:return DelayedCall.new()
	)

	func recycle()->void:
		if reset():
			s_pool.recycle(self)

	func progress()->float:
		if id>=0:return (worker.time-time)/delay
		return -1.0

	func update()->bool:
		if worker.time>=time+delay:
			var i:int=id
			invoke()
			if i==id:recycle()
			return false
		return true

class UpdatedCall extends Call:
	static var s_pool:Collections.Pool=Collections.Pool.new(
		func()->UpdatedCall:return UpdatedCall.new()
	)

	var duration:float

	func recycle()->void:
		if reset():
			duration=-1.0
			s_pool.recycle(self)

	func progress()->float:
		if id>=0 and duration>=0.0:
			return (worker.time-time-delay)/duration
		return -1.0

	func update()->bool:
		if worker.time>=time+delay:
			var i:int=id
			invoke()
			if duration>=0.0 and time+delay+duration>=worker.time:
				if i==id:recycle()
				return false
			return i==id
		return true

class RepeatedCall extends Call:
	static var s_pool:Collections.Pool=Collections.Pool.new(
		func()->RepeatedCall:return RepeatedCall.new()
	)

	var step:float
	var count:int
	var wait:float
	var tick:int=-1

	func recycle()->void:
		if reset():
			step=-1.0;count=-1
			wait=0.0;tick=-1
			s_pool.recycle(self)

	func progress()->float:
		if id>=0 and count>0:
			return maxi(tick,0)/float(count)
		return -1.0

	func update()->bool:
		var b:bool=false
		if worker.time>=time+delay:
			if tick<0:# Start
				wait=step;tick=1;b=true
			else:
				wait-=worker.delta
				if wait<=0.0:
					wait+=step;tick+=1;b=true
		if b:
			var i:int=id
			invoke()
			if count>0 and tick>=count:
				if i==id:recycle()
				return false
			return i==id
		return true
