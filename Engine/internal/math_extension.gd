class_name MathExtension

const k_epsilon:float=1E-5

static func float_clamp(v:float,a:float,z:float)->float:
	if a<z:return clamp(v,a,z)
	else:return v

static func vec3_lerp(a:Vector3,b:Vector3,t:Vector2,d:float)->Vector3:
	if t.x>0.0:return a.move_toward(b,t.x*d)
	elif t.x>=-1.0:return a.lerp(b,-t.x*t.y*d)
	return b

static func quat_lerp(a:Quaternion,b:Quaternion,t:Vector2,d:float)->Quaternion:
	if t.x>0.0:return a.slerp(b,clampf((t.x*d)/rad_to_deg(a.angle_to(b)),0.0,1.0))
	elif t.x>=-1.0:return a.slerp(b,-t.x*t.y*d)
	return b

static func looking_at(v:Vector3,n:Vector3=Vector3.UP)->Basis:
	v=v.normalized();var f:float=v.dot(n)
	if is_equal_approx(f,0.0) or is_equal_approx(f*f,1.0):return Basis.IDENTITY
	else:return Basis.looking_at(-v,n);

static func get_heading(b:Basis,n:Vector3=Vector3.UP)->Basis:
	var v:Vector3=b.get_rotation_quaternion()*Vector3.FORWARD
	v=v.slide(n);return Basis.looking_at(v.normalized(),n)
