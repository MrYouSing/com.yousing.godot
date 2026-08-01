class_name MathExtension

const k_int_max:int=0x7FFFFFFF
const k_epsilon:float=1E-5
const k_half_pi:float=PI*0.5
const k_two_pi:float=PI*2.0
const k_deg_to_rad:float=PI/180.0
const k_rad_to_deg:float=180.0/PI
const k_vec2_half:Vector2=Vector2.ONE*0.5
const k_vec3_half:Vector3=Vector3.ONE*0.5
const k_vec4_half:Vector4=Vector4.ONE*0.5
const k_vec2_nan:Vector2=Vector2(NAN,NAN)
const k_vec3_nan:Vector3=Vector3(NAN,NAN,NAN)
const k_vec4_nan:Vector4=Vector4(NAN,NAN,NAN,NAN)

# Math APIs

static func bool_to_sign(b:bool)->int:
	if b:return 1
	else:return -1

static func shorts_to_int(a:int,b:int)->int:
	return (mini(a,b)&0xFFFF)|((maxi(a,b)<<16)&0xFFFF0000)

static func int_to_shorts(i:int)->Vector2i:
	var a:int=i&0xFFFF;var b:int=(i>>16)&0xFFFF
	return Vector2i(mini(a,b),maxi(a,b))

static func var_to_int(v:Variant,i:int=0)->int:
	match typeof(v):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT,\
		TYPE_STRING,TYPE_STRING_NAME:i=int(v)
		TYPE_VECTOR2,TYPE_VECTOR2I:i=randi_range(v.x,v.y)
		_:i=v[randi()%v.size()]
	return i

static func var_to_float(v:Variant,f:float=0.0)->float:
	match typeof(v):
		TYPE_BOOL,TYPE_INT,TYPE_FLOAT,\
		TYPE_STRING,TYPE_STRING_NAME:f=float(v)
		TYPE_VECTOR2,TYPE_VECTOR2I:f=randf_range(v.x,v.y)
		_:f=v[randi()%v.size()]
	return f

static func str_to_mat(s:String,d:String=",")->Transform3D:
	var p:PackedStringArray=s.split(d)
	var a:Vector3;var b:Vector3;var c:Vector3
	match GodotExtension.s_dimension:
		3:
			match p.size():
				9:
					a=Vector3(float(p[0]),float(p[1]),float(p[2]))
					b=Vector3(float(p[3]),float(p[4]),float(p[5]))
					c=Vector3(float(p[6]),float(p[7]),float(p[8]))
				5:
					a=Vector3(float(p[0]),float(p[1]),float(p[2]))
					b=Vector3(0.0,float(p[3]),0.0)
					c=Vector3.ONE*float(p[4])
				3:
					a=Vector3(float(p[0]),0.0,float(p[1]))
					b=Vector3(0.0,float(p[2]),0.0)
					c=Vector3.ONE
	return Transform3D(Basis.from_euler(b*k_deg_to_rad).scaled_local(c),a)

static func mat_to_str(m:Transform3D,t:int=0,d:String=",",c:Callable=LangExtension.k_empty_callable)->String:
	if c.is_null():c=var_to_str
	var p:PackedStringArray
	var b:Basis=m.basis
	var v:Vector3=m.origin
	match t:
		0:
			p.append(c.call(v.x));p.append(c.call(v.y));p.append(c.call(v.z))
			v=b.get_euler()*k_deg_to_rad
			p.append(c.call(v.x));p.append(c.call(v.y));p.append(c.call(v.z))
			v=b.get_scale()
			p.append(c.call(v.x));p.append(c.call(v.y));p.append(c.call(v.z))
		1:
			p.append(c.call(v.x));p.append(c.call(v.y));p.append(c.call(v.z))
			v=b.get_euler()*k_deg_to_rad
			p.append(c.call(v.y))
			v=b.get_scale()
			p.append(c.call(v.x))
		2:
			p.append(c.call(v.x));p.append(c.call(v.z))
			v=b.get_euler()*k_deg_to_rad
			p.append(c.call(v.y))
	return d.join(p)

static func int_repeat(i:int,a:int,z:int=0)->int:
	if a<z:return wrapi(i,a,z)
	else:return (i+a)%a#wrapi(i,z,a)

static func int_wrap(i:int,n:int,b:bool)->int:
	if b:return (i+n)%n
	elif i<0:return 0
	elif i>=n:return n-1
	else:return i

static func float_clamp(v:float,a:float,z:float)->float:
	if a<z:return clampf(v,a,z)
	else:return v

## A safer version for [method @GlobalScope.remap]
static func float_remap(v:float,r:Vector4)->float:
	return lerpf(r.z,r.w,clampf((v-r.x)/(r.y-r.x),0.0,1.0))

static func degree_inside(r:float,a:float,z:float)->bool:
	r=wrapf(r-a,0.0,360.0)
	if is_zero_approx(r):return true
	z=wrapf(z-a,0.0,360.0)
	return r>0.0 and r<z# [a,z):range of wrapf()

static func radian_inside(r:float,a:float,z:float)->bool:
	r=wrapf(r-a,0.0,k_two_pi)
	if is_zero_approx(r):return true
	z=wrapf(z-a,0.0,k_two_pi)
	return r>0.0 and r<z# [a,z):range of wrapf()

static func time_alive(t:float,d:float)->bool:
	return d>=0.0 and t<=d

static func time_dead(t:float,d:float)->bool:
	return d>=0.0 and t>d

static func time_inside(t:float,a:float,z:float)->bool:
	return a!=z and t>=a and t<=z

static func time_outside(t:float,a:float,z:float)->bool:
	return a!=z and (t<a or t>z)

static func time_fade(a:float,b:float,t:float)->float:
	if t>=0.0:return t
	else:return absf(b-a)/-t

static func time_delta(f:float)->float:
	if is_zero_approx(f):return 0.0
	if f<0.0:f=-f/Application.get_fps()
	return f

static func time_tick(i:int,t:int=-1)->bool:
	if i==0:
		return true
	elif i>0:
		if t<0:t=Application.get_frames()
		return t%i==0
	else:
		return false

static func time_add(t:float,d:float)->float:
	if is_zero_approx(d):return 0.0
	t+=d;while t<=0.0:t+=d
	return t

static func random_index(a:Array[int],i:int,c:int)->int:
	var n:int=a.size();if n<=0:
		n=0;for it in c:if it!=i:a.append(it);n+=1
		a.shuffle()
	n-=1;i=a[n];a.remove_at(n)
	return i

static func random_level(f:float,a:PackedFloat32Array)->int:
	f*=randf()
	var i:int=-1;for it in a:
		i+=1;if f<it:return i# [,)
		f-=it# Next level.
	return i

static func float_to_time(f:float)->Vector4:
	if f<0.0:return Vector4.ZERO
	var h:float=floori(f/3600.0);f-=3600.0*h
	var m:float=floori(f/60.0);f-=60.0*m
	var s:float=floori(f);f-=s
	return Vector4(h,m,s,f)

# Geometry APIs

static func str_to_vec2(s:String,d:String=",",e:bool=true)->Vector2:
	var a:PackedFloat64Array=s.split_floats(d,e)
	return Vector2(a[0],a[1])

static func str_to_vec3(s:String,d:String=",",e:bool=true)->Vector3:
	var a:PackedFloat64Array=s.split_floats(d,e)
	return Vector3(a[0],a[1],a[2])

static func str_to_vec4(s:String,d:String=",",e:bool=true)->Vector4:
	var a:PackedFloat64Array=s.split_floats(d,e)
	return Vector4(a[0],a[1],a[2],a[3])

static func str_to_quat(s:String,d:String=",",e:bool=true)->Quaternion:
	var a:PackedFloat64Array=s.split_floats(d,e)
	if a.size()==3:return Basis.from_euler(Vector3(a[0],a[1],a[2]))
	return Quaternion(a[0],a[1],a[2],a[3])

static func str_to_rect(s:String,d:String=",",e:bool=true)->Rect2:
	var a:PackedFloat64Array=s.split_floats(d,e)
	return Rect2(a[0],a[1],a[2],a[3])

static func vec2_compare(a:Vector2,b:Vector2,t:float=k_epsilon)->int:
	var f:float=a.length_squared()
	var g:float=b.length_squared()
	if f<g:
		f=sqrt(f)-sqrt(g)
		if f*f>t*t:return -1
	elif f>g:
		f=sqrt(f)-sqrt(g)
		if f*f>t*t:return 1
	return 0

static func vec3_compare(a:Vector3,b:Vector3,t:float=k_epsilon)->int:
	var f:float=a.length_squared()
	var g:float=b.length_squared()
	if f<g:
		f=sqrt(f)-sqrt(g)
		if f*f>t*t:return -1
	elif f>g:
		f=sqrt(f)-sqrt(g)
		if f*f>t*t:return 1
	return 0

static func float_lerp(a:float,b:float,t:Vector2,d:float)->float:
	if t.x>0.0:return clampf(a+t.x*d,a,b)
	elif t.x>=-1.0:return lerpf(a,b,-t.x*t.y*d)
	return b

static func vec2_lerp(a:Vector2,b:Vector2,t:Vector2,d:float)->Vector2:
	if t.x>0.0:return a.move_toward(b,t.x*d)
	elif t.x>=-1.0:return a.lerp(b,-t.x*t.y*d)
	return b

static func vec3_lerp(a:Vector3,b:Vector3,t:Vector2,d:float)->Vector3:
	if t.x>0.0:return a.move_toward(b,t.x*d)
	elif t.x>=-1.0:return a.lerp(b,-t.x*t.y*d)
	return b

static func quat_lerp(a:Quaternion,b:Quaternion,t:Vector2,d:float)->Quaternion:
	if t.x>0.0:return a.slerp(b,clampf((t.x*d)/rad_to_deg(a.angle_to(b)),0.0,1.0))
	elif t.x>=-1.0:return a.slerp(b,-t.x*t.y*d)
	return b

static func pose_lerp(a:Transform3D,b:Transform3D,t:Vector2,d:float)->Transform3D:
	var x:Basis=a.basis;var y:Basis=b.basis
	var p:Vector3=vec3_lerp(a.origin,b.origin,t,d)
	var r:Quaternion=quat_lerp(x.get_rotation_quaternion(),y.get_rotation_quaternion(),t,d)
	return Transform3D(Basis(r),p)

static func trans_lerp(a:Transform3D,b:Transform3D,t:Vector2,d:float)->Transform3D:
	var x:Basis=a.basis;var y:Basis=b.basis
	var p:Vector3=vec3_lerp(a.origin,b.origin,t,d)
	var r:Quaternion=quat_lerp(x.get_rotation_quaternion(),y.get_rotation_quaternion(),t,d)
	var s:Vector3=vec3_lerp(x.get_scale(),y.get_scale(),t,d)
	return Transform3D(Basis(r).scaled_local(s),p)

static func float_fade(a:float,b:float,c:float)->float:
	var d:float=c*c
	if a*a<d:
		if b*b>=d:a=b
		a=signf(a)*c
	return a

static func vec2_fade(a:Vector2,b:Vector2,c:float)->Vector2:
	var d:float=c*c
	if a.length_squared()<d:
		if b.length_squared()>=d:a=b
		a=a.normalized()*c
	return a

static func vec2_inside(v:Vector2,a:Vector2,z:Vector2)->bool:
	if a.x<z.x:
		if v.x<a.x:return false
		if v.x>z.x:return false
	elif a.x>z.x:
		if v.x>a.x:return false
		if v.x<z.x:return false
	if a.y<z.y:
		if v.y<a.y:return false
		if v.y>z.y:return false
	elif a.y>z.y:
		if v.y>a.y:return false
		if v.y<z.y:return false
	return true

static func vec3_parallel(a:Vector3,b:Vector3)->int:
	var f:float=a.normalized().dot(b.normalized())
	if is_zero_approx(f*f-1.0):
		if f>0.0:return 1
		else:return -1
	return 0

static func rect_position(r:Rect2,p:Vector2)->Vector2:
	var a:Vector2=r.position;var z:Vector2=a+r.size
	return Vector2(lerpf(a.x,z.x,p.x),lerpf(a.y,z.y,p.y))

## Full version of [method Rect2.has_point].
static func rect_contain(r:Rect2,p:Vector2)->bool:
	var a:Vector2=r.position;var z:Vector2=a+r.size
	return p.x>=a.x and p.y>=a.y and p.x<=z.x and p.y<=z.y

## 2D-Version [method Basis.looking_at].
static func clocking_at(v:Vector2)->float:
	if v.is_zero_approx():return 0.0
	else:return atan2(v.x,-v.y)

static func looking_at(v:Vector3,n:Vector3=Vector3.UP)->Basis:
	var f:float=v.length_squared()
	if is_zero_approx(f+n.length_squared()):return Basis.IDENTITY
	v/=sqrt(f);f=v.dot(n)
	if is_zero_approx(f*f-1.0):return Basis.IDENTITY
	else:return Basis.looking_at(-v,n)

static func get_heading(b:Basis,n:Vector3=Vector3.UP)->Basis:
	var v:Vector3=b.get_rotation_quaternion()*Vector3.FORWARD
	v=v.slide(n);if is_zero_approx(v.length_squared()):return Basis.IDENTITY
	return Basis.looking_at(v,n)

static func angle_between(a:Vector3,b:Vector3,n:Vector3=Vector3.UP)->float:
	if n.length_squared()>0.0:
		a=a.slide(n).normalized()
		b=b.slide(n).normalized()
	var f:float=acos(a.dot(b))*k_rad_to_deg
	if n.dot(a.cross(b))>=0.0:return f
	else:return -f

static func rotate_between(a:Vector3,b:Vector3,n:Vector3=Vector3.UP)->Basis:
	return Quaternion(a,b)

## Another [method Basis.looking_at] for ray-casting.
static func reflecting_at(a:Vector3,b:Vector3,n:Vector3=Vector3.UP,q:Basis=Basis.IDENTITY)->Basis:
	match vec3_parallel(b,n):
		1:return looking_at((-a).slide(n),n)*q
		-1:return looking_at((-a).slide(n),n)*q.inverse()
		0:return looking_at(b,n)
		_:return q

## Another [method Basis.looking_at] for ray-aiming.
static func aiming_at(v:Vector3)->Basis:
	match vec3_parallel(v,Vector3.UP):
		-1:return Basis(Vector3.LEFT,MathExtension.k_half_pi)
		1:return Basis(Vector3.RIGHT,MathExtension.k_half_pi)
		_:return looking_at(v)
