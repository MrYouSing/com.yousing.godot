// Taken from https://gameidea.org/2023/12/01/film-grain-shader/.
shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture;

uniform float weight:hint_range(0.0,1.0)=1.0;
uniform float grain:hint_range(0.0,10.0)=0.05;
uniform float rate:hint_range(0.001,10.0)=0.001;

void fragment(){
	vec4 color=texture(screen_texture,SCREEN_UV);vec3 rgb=color.rgb;
	float time=TIME;time=mix(time,floor(time/rate)*rate,step(0.0015,rate));
	float noise=(fract(sin(dot(UV*time,vec2(12.9898,78.233)))*43758.5453)-0.5)*2.0;
	rgb=clamp(rgb+(noise*grain),0.0,1.0);
	COLOR=mix(color,vec4(rgb,color.a),weight);
}
