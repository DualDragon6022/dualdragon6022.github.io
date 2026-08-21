#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0, depthtex0;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse;
uniform vec3 skyColor, cameraPosition, sunPosition;
uniform float frameTimeCounter, sunAngle, rainStrength;
in vec2 uv; layout(location=0) out vec4 outC;
vec3 palette(float x){return 0.5+0.5*cos(6.2832*(x+vec3(0.0,0.33,0.67)));}
void main(){
 if(texture(depthtex0,uv).r<1.0){outC=texture(colortex0,uv);return;}
 vec4 vp=gbufferProjectionInverse*vec4(uv*2.0-1.0,1.0,1.0);
 vec3 dir=normalize((gbufferModelViewInverse*vec4(vp.xyz,0.0)).xyz);
 vec3 sd=normalize((gbufferModelViewInverse*vec4(sunPosition,0.0)).xyz);
 float night=nightF(sunAngle), sunset=sunsetF(sunAngle);
 float hor=1.0-abs(dir.y);
 float glow=pow5(max(0.0,dot(dir,sd)));
 #if STYLE==0
 vec3 sky=mix(skyColor*0.9,mix(skyColor*1.4,vec3(1.0,0.5,0.2),sunset),hor*hor);
 #else
 vec3 sky=mix(skyColor*1.15,mix(vec3(0.8,0.85,1.0)*(skyColor.b*1.6+0.2),vec3(1.0,0.42,0.18),sunset),fastSmooth(hor));
 #endif
 sky+=vec3(1.0,0.45,0.15)*glow*(0.4+sunset*(2.0+float(STYLE)));
 sky+=vec3(1.0,0.9,0.7)*pow5(pow5(max(0.0,dot(dir,sd))))*4.0*(1.0-night); // sun disc glow
 sky=mix(sky,sky*vec3(0.10,0.12,0.22)+vec3(0.01,0.012,0.02),night);
 sky+=vec3(0.8,0.85,1.0)*pow5(pow5(max(0.0,dot(dir,-sd))))*0.6*night;     // moon glow
 #ifdef NIGHT_NEBULA
 if(night>0.01&&dir.y>0.0){
  vec2 q=dir.xz/(dir.y+0.4)*3.0+frameTimeCounter*0.003;
  vec3 neb=vec3(0.0);float a=0.6;
  for(int i=0;i<NEBULA_OCTAVES;i++){neb+=palette(vnoise(q)+0.55)*vnoise(q*1.7)*a;q=q*2.13+17.0;a*=0.5;}
  sky+=neb*neb*0.4*night*dir.y;
  vec2 sc=floor(dir.xz/max(dir.y,0.1)*300.0);
  float st=step(0.996,hash(sc));
  sky+=vec3(st)*(0.6+0.4*sin(frameTimeCounter*3.0+hash(sc+9.0)*17.0))*night*fastSmooth(dir.y); // twinkle
 }
 #endif
 #ifdef CUSTOM_CLOUDS
 if(dir.y>0.02){
  float t0=(192.0-cameraPosition.y)/dir.y;
  vec2 p=(cameraPosition.xz+dir.xz*t0)*0.003+frameTimeCounter*0.01;
  float d=0.0,amp=0.55;
  for(int i=0;i<3;i++){d+=vnoise(p)*amp;p=p*2.4+13.0;amp*=0.5;}
  float ds=0.0;amp=0.55;vec2 ps=p*0.0+((cameraPosition.xz+dir.xz*t0)+sd.xz*30.0)*0.003+frameTimeCounter*0.01;
  for(int i=0;i<3;i++){ds+=vnoise(ps)*amp;ps=ps*2.4+13.0;amp*=0.5;}
  float cov=fastSmooth(clamp((d-0.45)*3.0,0.0,1.0))*(1.0-rainStrength*0.3);
  float shade=clamp(1.0-(ds-d)*2.0,0.4,1.0);
  vec3 cc=mix(vec3(0.10,0.12,0.18),mix(vec3(1.05),vec3(1.15,0.55,0.3),sunset)*shade,1.0-night*0.9);
  sky=mix(sky,cc,cov*fastSmooth(min(dir.y*3.0,1.0)));
 }
 #endif
 outC=vec4(sky,1.0);
}
