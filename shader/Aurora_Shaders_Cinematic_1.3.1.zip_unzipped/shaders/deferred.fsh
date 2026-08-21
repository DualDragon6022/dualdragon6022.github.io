#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0,depthtex0;uniform mat4 gbufferProjectionInverse,gbufferModelViewInverse;uniform vec3 skyColor,cameraPosition,sunPosition;uniform float frameTimeCounter,sunAngle,rainStrength;in vec2 uv;layout(location=0) out vec4 outC;
vec3 palette(float x){return 0.5+0.5*cos(6.2832*(x+vec3(0.0,0.33,0.67)));}
void main(){if(texture(depthtex0,uv).r<1.0){outC=texture(colortex0,uv);return;}vec4 vp=gbufferProjectionInverse*vec4(uv*2.0-1.0,1.0,1.0);vec3 dir=normalize((gbufferModelViewInverse*vec4(vp.xyz,0.0)).xyz);vec3 sd=normalize((gbufferModelViewInverse*vec4(sunPosition,0.0)).xyz);float night=nightF(sunAngle),sunset=sunsetF(sunAngle),hor=1.0-abs(dir.y);float glow=pow5(max(0.0,dot(dir,sd)));vec3 sky=mix(skyColor*1.15,mix(vec3(0.8,0.85,1.0)*(skyColor.b*1.6+0.2),vec3(1.0,0.42,0.18),sunset),fastSmooth(hor));sky+=vec3(1.0,0.45,0.15)*glow*(0.45+sunset*(2.2+float(STYLE)));sky+=vec3(1.0,0.9,0.7)*pow5(pow5(max(0.0,dot(dir,sd))))*4.0*(1.0-night);sky=mix(sky,sky*vec3(0.10,0.12,0.22)+vec3(0.01,0.012,0.02),night);sky+=vec3(0.8,0.85,1.0)*pow5(pow5(max(0.0,dot(dir,-sd))))*0.7*night;
#ifdef NIGHT_NEBULA
if(night>0.01&&dir.y>0.0){vec2 q=dir.xz/(dir.y+0.4)*3.0+frameTimeCounter*0.003;vec3 neb=vec3(0.0);float a=0.6;for(int i=0;i<NEBULA_OCTAVES;i++){neb+=palette(vnoise(q)+0.55)*vnoise(q*1.7)*a;q=q*2.13+17.0;a*=0.5;}sky+=neb*neb*0.45*night*dir.y;vec2 sc=floor(dir.xz/max(dir.y,0.1)*300.0);float st=step(0.996,hash(sc));sky+=vec3(st)*(0.6+0.4*sin(frameTimeCounter*3.0+hash(sc+9.0)*17.0))*night*fastSmooth(dir.y);}
#endif
#ifdef AURORA_RIBBONS
if(night>0.15&&dir.y>0.04){vec2 aq=dir.xz/(dir.y+0.25)*2.5;float bands=0.0,a=0.6;for(int i=0;i<AURORA_DETAIL;i++){float n=vnoise(aq*float(i+1)*1.5+frameTimeCounter*0.01);bands+=sin(aq.x*(2.0+float(i)*0.7)+n*5.0+frameTimeCounter*(1.0+float(i)*0.2))*a;a*=0.5;}float curtain=exp(-bands*bands*0.85)*fastSmooth(clamp(dir.y*2.5,0.0,1.0));vec3 ac=mix(vec3(0.06,0.75,0.42),vec3(0.45,0.18,0.95),fastSmooth(sin(aq.x*0.65+frameTimeCounter*0.03)*0.5+0.5));sky+=ac*curtain*(0.07+0.025*float(AURORA_DETAIL))*night;}
#endif
#ifdef FIREFLIES
if(night>0.25&&dir.y>-0.04&&dir.y<0.5){vec2 fq=dir.xz/(max(dir.y+0.35,0.08))*180.0;vec2 cell=floor(fq),ff=fract(fq)-0.5;float fid=hash(cell);float f=step(0.9975,fid);float pulse=0.5+0.5*sin(frameTimeCounter*(1.5+fid*3.0)+fid*40.0);sky+=vec3(0.48,1.0,0.34)*f*exp(-dot(ff,ff)*180.0)*pulse*night*0.12;}
#endif
#ifdef CUSTOM_CLOUDS
if(dir.y>0.02){float t0=(192.0-cameraPosition.y)/dir.y;vec2 p=(cameraPosition.xz+dir.xz*t0)*0.003+frameTimeCounter*0.008;float d=0.0,a=0.55;for(int i=0;i<CLOUD_OCTAVES;i++){d+=vnoise(p)*a;p=p*2.35+13.0;a*=0.5;}float ds=0.0;a=0.55;vec2 ps=p*0.0+((cameraPosition.xz+dir.xz*t0)+sd.xz*30.0)*0.003+frameTimeCounter*0.008;for(int i=0;i<CLOUD_OCTAVES;i++){ds+=vnoise(ps)*a;ps=ps*2.35+13.0;a*=0.5;}float cov=fastSmooth(clamp((d-0.46)*3.1,0.0,1.0))*(1.0-rainStrength*0.28);float shade=clamp(1.0-(ds-d)*2.2,0.35,1.0);vec3 cc=mix(vec3(0.10,0.12,0.18),mix(vec3(1.05),vec3(1.15,0.55,0.3),sunset)*shade,1.0-night*0.9);sky=mix(sky,cc,cov*fastSmooth(min(dir.y*3.0,1.0)));}
#endif
#ifdef ATMOSPHERIC_SCATTER
float haze=pow(clamp(1.0-abs(dir.y),0.0,1.0),3.0);vec3 hazeCol=mix(vec3(0.30,0.48,0.70),vec3(0.9,0.34,0.18),sunset);sky=mix(sky,hazeCol,haze*0.035*(0.4+0.6*(1.0-night)));
#endif
outC=vec4(sky,1.0);}
