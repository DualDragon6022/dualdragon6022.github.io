#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0,depthtex0;uniform mat4 gbufferProjectionInverse,gbufferModelViewInverse;uniform vec3 skyColor,cameraPosition,sunPosition;uniform float frameTimeCounter,sunAngle,rainStrength;in vec2 uv;layout(location=0) out vec4 outC;
void main(){float depth=texture(depthtex0,uv).r;if(depth<0.99999){outC=texture(colortex0,uv);return;}vec4 vp=gbufferProjectionInverse*vec4(uv*2.0-1.0,1.0,1.0);vec3 dir=normalize((gbufferModelViewInverse*vec4(vp.xyz,0.0)).xyz);vec3 sd=normalize((gbufferModelViewInverse*vec4(sunPosition,0.0)).xyz);float night=nightF(sunAngle),sunset=sunsetF(sunAngle),day=dayF(sunAngle);float horizon=fastSmooth(clamp(1.0-abs(dir.y),0.0,1.0));float sunGlow=pow5(max(0.0,dot(dir,sd)));vec3 zenith=mix(vec3(0.34,0.54,0.82),vec3(0.045,0.07,0.14),night);vec3 horizonCol=mix(vec3(0.78,0.88,1.0),vec3(0.20,0.25,0.42),night);horizonCol=mix(horizonCol,vec3(1.0,0.43,0.16),sunset);vec3 sky=mix(zenith,horizonCol,horizon);sky+=vec3(1.0,0.43,0.14)*sunGlow*(0.35+1.8*sunset+0.55*day);sky+=vec3(1.0,0.92,0.75)*pow5(pow5(max(0.0,dot(dir,sd))))*2.8*day;
#ifdef NIGHT_NEBULA
if(night>0.02&&dir.y>0.0){vec2 q=dir.xz/(dir.y+0.5)*2.2+frameTimeCounter*0.003;float n=fbm(q,NEBULA_OCTAVES);vec3 neb=0.5+0.5*cos(6.2832*(n+vec3(0.0,0.27,0.57)));sky+=neb*n*n*0.28*night*dir.y;vec2 sc=floor(dir.xz/max(dir.y,0.1)*360.0);float st=step(0.997,hash(sc));sky+=vec3(st)*0.45*night*fastSmooth(dir.y);}
#endif
#ifdef AURORA_RIBBONS
if(night>0.12&&dir.y>0.03){vec2 aq=dir.xz/(dir.y+0.28)*2.3;float b=0.0,a=0.55;for(int i=0;i<AURORA_DETAIL;i++){float n=vnoise(aq*(1.3+float(i)*0.7)+frameTimeCounter*0.01);b+=sin(aq.x*(2.2+float(i)*0.8)+n*4.5+frameTimeCounter*(0.9+float(i)*0.2))*a;a*=0.5;}float curtain=exp(-b*b*0.95)*fastSmooth(clamp(dir.y*2.7,0.0,1.0));vec3 ac=mix(vec3(0.06,0.72,0.38),vec3(0.46,0.20,0.88),fastSmooth(sin(aq.x*0.6+frameTimeCounter*0.025)*0.5+0.5));sky+=ac*curtain*0.09*night;}
#endif
#ifdef CUSTOM_CLOUDS
if(dir.y>0.025){float t=(192.0-cameraPosition.y)/dir.y;vec2 p=(cameraPosition.xz+dir.xz*t)*0.0019+frameTimeCounter*0.006;float d=fbm(p,CLOUD_OCTAVES);float p2=fbm(p*0.57+vec2(31.7,11.4),5);float cov=fastSmooth(clamp((d*0.72+p2*0.28-0.48)*3.5,0.0,1.0));float edge=fastSmooth(clamp((d*0.72+p2*0.28-0.43)*5.0,0.0,1.0));vec3 cc=mix(vec3(0.15,0.17,0.22),mix(vec3(1.0),vec3(1.0,0.52,0.25),sunset),day);sky=mix(sky,cc,cov*fastSmooth(clamp(dir.y*4.0,0.0,1.0))*0.82);}
#endif
float nightFloor=night*0.055;sky+=vec3(0.018,0.025,0.05)*nightFloor;outC=vec4(max(sky,vec3(0.0)),1.0);}
