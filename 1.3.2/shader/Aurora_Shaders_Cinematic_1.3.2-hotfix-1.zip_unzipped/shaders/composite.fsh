#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0, colortex1, colortex2, depthtex0, shadowtex1;
uniform mat4 gbufferProjectionInverse, gbufferModelViewInverse, shadowModelView, shadowProjection;
uniform vec3 shadowLightPosition, cameraPosition, skyColor;
uniform float frameTimeCounter, sunAngle; uniform int isEyeInWater;
in vec2 uv; layout(location=0) out vec4 outC;
vec3 toShadow(vec3 wp){vec4 s=shadowProjection*(shadowModelView*vec4(wp,1.0));return distortS(s.xyz)*0.5+0.5;}
void main(){
 vec3 color=texture(colortex0,uv).rgb;
 float depth=texture(depthtex0,uv).r;
 vec4 vp4=gbufferProjectionInverse*vec4(vec3(uv,depth)*2.0-1.0,1.0);
 vec3 viewPos=vp4.xyz/vp4.w;
 vec3 worldPos=(gbufferModelViewInverse*vec4(viewPos,1.0)).xyz;
 float dither=ign(gl_FragCoord.xy);
 bool sky=depth>=1.0;
 float sunset=sunsetF(sunAngle), day=dayF(sunAngle);
 vec4 g2=texture(colortex2,uv);
 #ifdef DYNAMIC_SHADOWS
 if(!sky){
  vec3 sp=toShadow(worldPos);sp.z-=0.0012;
  float a=dither*6.2832;vec2 r=vec2(cos(a),sin(a))*(1.6/float(shadowMapResolution));
  const vec2 o[4]=vec2[](vec2(1,0),vec2(-1,0),vec2(0,1),vec2(0,-1));
  float sh=0.0;
  for(int i=0;i<4;i++)sh+=step(sp.z,texture(shadowtex1,sp.xy+vec2(r.x*o[i].x-r.y*o[i].y,r.y*o[i].x+r.x*o[i].y)).r);
  sh=sh*0.25*g2.y;
  float NdotL=texture(colortex1,uv).a;
  vec3 amb=skyColor*(0.30+0.15*float(STYLE))*g2.y+vec3(0.035);
  #ifdef COLORED_BLOCKLIGHT
  vec3 bc=mix(vec3(1.0,0.62,0.3),vec3(0.4,0.7,1.0),clamp(g2.z*2.0,0.0,1.0));
  amb+=bc*fastSmooth(g2.x)*g2.x*1.6;
  #endif
  amb+=vec3(step(0.25,g2.z))*0.8; // emissive blocks self-light
  color*=amb+lightCol(sunAngle)*sh*NdotL*(day+0.05);
 }
 #endif
 #ifdef VOLUMETRIC_LIGHT
 {
  vec3 endW=sky?normalize(worldPos)*64.0:worldPos;
  vec3 s0=toShadow(vec3(0.0)),s1=toShadow(endW);
  vec3 stp=(s1-s0)/float(VL_SAMPLES);vec3 sp=s0+stp*dither;
  float vl=0.0;
  for(int i=0;i<VL_SAMPLES;i++,sp+=stp)vl+=step(sp.z-0.001,texture(shadowtex1,sp.xy).r);
  float mu=dot(normalize(viewPos),normalize(shadowLightPosition));
  float k=(STYLE==1)?0.72:0.5;
  float ph=(1.0-k*k)/(12.566*(1.0-k*mu)*(1.0-k*mu));
  color+=lightCol(sunAngle)*(vl/float(VL_SAMPLES))*ph*((STYLE==1)?0.9:0.45);
 }
 #endif
 #ifdef CUSTOM_FOG
 if(!sky){
  float d2=distSq(worldPos);
  #if STYLE==0
  float fog=1.0-fastExp(-d2*2.2e-5);
  #else
  float hf=max(0.0,64.0-(worldPos.y+cameraPosition.y))*0.02;
  float fog=clamp(1.0-fastExp(-d2*6.0e-5-hf*(1.0-fastExp(-d2*4e-4))),0.0,1.0);
  #endif
  color=mix(color,mix(skyColor,vec3(1.0,0.5,0.25),sunset)*(dayF(sunAngle)*0.9+0.1),fog);
 }
 #endif
 #ifdef UNDERWATER_FX
 if(isEyeInWater==1){
  float dist=min(length(viewPos),48.0);
  color*=fastExp(-dist*vec3(0.35,0.10,0.06));
  color+=vec3(0.0,0.09,0.14)*(1.0-fastExp(-dist*0.1));
  if(!sky){
   float t=frameTimeCounter*1.5;vec3 wp=worldPos+cameraPosition;
   float ca=sin(wp.x*2.5+t)*sin(wp.z*2.5-t*1.3);
   color*=1.0+max(0.0,ca)*0.35*g2.y;
  }
 }
 #endif
 outC=vec4(color,1.0);
}
