class_name MathExtension

const k_epsilon:float=1E-5
const k_deg_to_rad:float=PI/180.0
const k_rad_to_deg:float=180.0/PI
const k_vec2_half:Vector2=Vector2.ONE*0.5
const k_vec3_half:Vector3=Vector3.ONE*0.5
const k_vec4_half:Vector4=Vector4.ONE*0.5

# Math APIs

static func float_clamp(v:float,a:float,z:float)->float:
	if a<z:return clamp(v,a,z)
	else:return v

## A safer version for [method @GlobalScope.remap]
static func float_remap(v:float,r:Vector4)->float:
	return lerpf(r.z,r.w,clampf((v-r.x)/(r.y-r.x),0.0,1.0))

static func time_alive(t:float,d:float)->bool:
	return d>=0.0 and t<=d

static func time_dead(t:float,d:float)->bool:
	return d>=0.0 and t>d

static func time_inside(t:float,a:float,z:float)->bool:
	return a!=z and t>=a and t<=z

static func time_outside(t:float,a:float,z:float)->bool:
	return a!=z and (t<a or t>z)

static func time_fade(o:float,n:float,t:float)->float:
	if t>=0.0:return t
	else:return absf(n-o)/-t

static func random_level(f:float,a:Array[float])->int:
	f*=randf()
	var i:int=-1;for it in a:
		i+=1;if f<it:return i# [,)
		f-=it# Next level.
	return i

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

static func vec3_lerp(a:Vector3,b:Vector3,t:Vector2,d:float)->Vector3:
	if t.x>0.0:return a.move_toward(b,t.x*d)
	elif t.x>=-1.0:return a.lerp(b,-t.x*t.y*d)
	return b

static func quat_lerp(a:Quaternion,b:Quaternion,t:Vector2,d:float)->Quaternion:
	if t.x>0.0:return a.slerp(b,clampf((t.x*d)/rad_to_deg(a.angle_to(b)),0.0,1.0))
	elif t.x>=-1.0:return a.slerp(b,-t.x*t.y*d)
	return b

static func vec3_parallel(a:Vector3,b:Vector3)->int:
	var f:float=a.normalized().dot(b.normalized())
	if is_zero_approx(f*f-1.0):
		if f>0.0:return 1
		else:return -1
	return 0

## 2D-Version [method Basis.looking_at].
static func clocking_at(v:Vector2)->float:
	if v.is_zero_approx():return 0.0
	else:return atan2(v.x,-v.y)

static func looking_at(v:Vector3,n:Vector3=Vector3.UP)->Basis:
	var f:float=v.length_squared()
	if is_zero_approx(f+n.length_squared()):return Basis.IDENTITY
	v/=sqrt(f);f=v.dot(n)
	if is_zero_approx(f*f-1.0):return Basis.IDENTITY
	else:return Basis.looking_at(-v,n);

static func get_heading(b:Basis,n:Vector3=Vector3.UP)->Basis:
	var v:Vector3=b.get_rotation_quaternion()*Vector3.FORWARD
	v=v.slide(n);return Basis.looking_at(v.normalized(),n)

static func rotate_between(a:Vector3,b:Vector3,n:Vector3=Vector3.UP)->Basis:
	return looking_at(b,n)*looking_at(a,n).inverse()

## Another [method Basis.looking_at] for ray-casting.
static func reflecting_to(a:Vector3,b:Vector3,n:Vector3=Vector3.UP,q:Basis=Basis.IDENTITY)->Basis:
	match vec3_parallel(b,n):
		1:return looking_at((-a).slide(n),n)*q
		-1:return looking_at((-a).slide(n),n)*q.inverse()
		0:return looking_at(b,n)
		_:return q
