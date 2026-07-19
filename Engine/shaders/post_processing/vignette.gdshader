// Taken from com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl#L91.
// Taken from com.unity.render-pipelines.universal/Runtime/Passes/PostProcess/UberPostProcessPass.cs#L570.
shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture;
uniform vec2 center=vec2(0.5,0.5);
uniform vec4 tint:source_color=vec4(0.0,0.0,0.0,1.0);
uniform float intensity:hint_range(0.0,1.0)=0.0;
uniform float smoothness:hint_range(0.01,1.0)=0.2;
uniform float rounded;

void fragment() {
	vec4 color=texture(screen_texture,SCREEN_UV);vec3 rgb=color.rgb;
	vec2 v=abs(SCREEN_UV-center)*intensity*3.0;
	v.x*=mix(1.0,SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x,step(0.5,rounded));// Move to GDScript.
	float f=pow(clamp(1.0-dot(v,v),0.0,1.0),smoothness*5.0);
	rgb*=mix(tint.rgb,vec3(1.0),f);
	COLOR=mix(color,vec4(rgb,1.0),tint.a);
}
