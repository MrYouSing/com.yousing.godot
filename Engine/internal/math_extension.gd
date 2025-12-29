class_name MathExtension

const k_epsilon:float=1E-5
const k_deg_to_rad:float=PI/180.0
const k_rad_to_deg:float=180.0/PI

# Math APIs

static func float_clamp(v:float,a:float,z:float)->float:
	if a<z:return clamp(v,a,z)
	else:return v

static func time_alive(t:float,d:float)->bool:
	return d>=0.0 and t<=d

static func time_dead(t:float,d:float)->bool:
	return d>=0.0 and t>d

static func time_inside(t:float,a:float,z:float)->bool:
	return a!=z and t>=a and t<=z

static func time_outside(t:float,a:float,z:float)->bool:
	return a!=z and (t<a or t>z)

static func random_level(f:float,a:Array[float])->int:
	f*=randf()
	var i:int=-1;for it in a:
		i+=1;if f<it:return i# [,)
		f-=it# Next level.
	return i

# Geometry APIs

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
