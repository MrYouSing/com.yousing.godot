// Taken from com.unity.render-pipelines.universal/Shaders/PostProcessing/UberPost.shader#L129.
// Taken from com.unity.render-pipelines.universal/Runtime/Passes/PostProcess/UberPostProcessPass.cs#L462.
shader_type canvas_item;

#define DistCenter _Distortion_Params1.xy
#define DistAxis _Distortion_Params1.zw
#define DistTheta _Distortion_Params2.x
#define DistSigma _Distortion_Params2.y
#define DistScale _Distortion_Params2.z
#define DistIntensity _Distortion_Params2.w

uniform sampler2D screen_texture:hint_screen_texture;
uniform float weight:hint_range(0.0,1.0)=1.0;
uniform float intensity:hint_range(-1.0,1.0)=0.0;
uniform vec2 center=vec2(0.5,0.5);
uniform vec2 axis=vec2(1.0,1.0);
uniform float scale:hint_range(0.01,5.0)=1.0;

varying vec4 _Distortion_Params1;
varying vec4 _Distortion_Params2;

vec2 distort(vec2 uv){
	uv=(uv-0.5)*DistScale+0.5;
	vec2 ruv=DistAxis*(uv-0.5-DistCenter);
	float ru=length(ruv);
	if(DistIntensity>=0.0){
		float wu=ru*DistTheta;
		ru=tan(wu)*(1.0/(ru*DistSigma));
		uv=uv+ruv*(ru-1.0);
	}else{
		ru=1.0/(ru)*DistTheta*atan(ru*DistSigma);
		uv=uv+ruv*(ru-1.0);
	}
	return uv;
}

void vertex() {// Move to GDScript.
	float amount=1.6*max(abs(intensity*100.0),1.0);
	float theta=0.01745329252*min(160.0,amount);
	float sigma=2.0*tan(theta*0.5);
	vec2 point=center*2.0-vec2(1.0,1.0);
	_Distortion_Params1=vec4(
		point.x,
		point.y,
		max(axis.x,1e-4),
		max(axis.y,1e-4)
	);
	_Distortion_Params2=vec4(
		intensity>=0.0?theta:1.0/theta,
		sigma,
		1.0/scale,
		intensity*100.0
	);
}

void fragment(){
	vec4 color=texture(screen_texture,SCREEN_UV);
	vec2 uv=distort(SCREEN_UV);
	vec3 rgb=texture(screen_texture,uv).rgb;
	COLOR=mix(color,vec4(rgb,color.a),weight);
}