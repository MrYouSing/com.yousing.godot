#define #PLATFORM 1
#define #QUALITY

#ifdef Quality_High
vec3 linear_to_srgb(vec3 c){
	return vec3(
		c.r<0.0031308f?12.92f*c.r:(1.0+0.055)*pow(c.r,1.0f/2.4f)-0.055,
		c.g<0.0031308f?12.92f*c.g:(1.0+0.055)*pow(c.g,1.0f/2.4f)-0.055,
		c.b<0.0031308f?12.92f*c.b:(1.0+0.055)*pow(c.b,1.0f/2.4f)-0.055
	);
}
vec3 srgb_to_linear(vec3 c){
	return vec3(
		c.r<0.04045f?c.r*(1.0f/12.92f):pow(float((c.r+0.055)*(1.0/(1.0+0.055))),2.4f),
		c.g<0.04045f?c.g*(1.0f/12.92f):pow(float((c.g+0.055)*(1.0/(1.0+0.055))),2.4f),
		c.b<0.04045f?c.b*(1.0f/12.92f):pow(float((c.b+0.055)*(1.0/(1.0+0.055))),2.4f)
	);
}
#else
vec3 linear_to_srgb(vec3 c){return pow(c,vec3(1.0/2.2));}
vec3 srgb_to_linear(vec3 c){return pow(c,vec3(2.2));}
#endif

#ifdef Windows
#define BEGIN_COLOR(x) x=linear_to_srgb(x)
#define END_COLOR(x) x=srgb_to_linear(x)
#else
#define BEGIN_COLOR(x) 
#define END_COLOR(x) 
#endif