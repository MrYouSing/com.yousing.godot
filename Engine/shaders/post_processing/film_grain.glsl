#version #VERSION
#include "res://addons/yousing/Engine/shaders/internal/core.glsl"

layout(local_size_x=8,local_size_y=8,local_size_z=1) in;
layout(rgba16f,set=0,binding=0) uniform image2D color_image;
layout(push_constant,std430) uniform Params{
	vec2 size;
	float time;
	float weight;
	float grain;//:hint_range(0.0,10.0)=0.05;
	vec2 reserved;
}params;

void main(){
	ivec2 px=ivec2(gl_GlobalInvocationID.xy);
	ivec2 size=ivec2(params.size);
	if(px.x>=size.x||px.y>=size.y){return;}
	vec4 color=imageLoad(color_image,px);
	vec3 rgb=color.rgb;float a=color.a;
	// Taken from https://gameidea.org/2023/12/01/film-grain-shader/.
	BEGIN_COLOR(rgb);
	vec2 UV=vec2(px)/size;
	float noise=(fract(sin(dot(UV*params.time,vec2(12.9898,78.233)))*43758.5453)-0.5)*2.0;
	rgb=max(rgb+(noise*params.grain),0.0);
	END_COLOR(rgb);
	//
	color=mix(color,vec4(rgb,a),params.weight);
	imageStore(color_image,px,color);
}