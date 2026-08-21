#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0, depthtex0;
uniform mat4 gbufferProjection;
uniform vec3 sunPosition, moonPosition;
uniform float sunAngle;
in vec2 uv; layout(location=0) out vec4 outC;
void main(){
 vec3 color=texture(colortex0,uv).rgb;
 #ifdef LIGHT_SHAFTS
 vec3 lp=(sunAngle<0.5)?sunPosition:moonPosition;
 vec4 cp=gbufferProjection*vec4(lp,1.0);
 vec2 sunUV=cp.xy/cp.w*0.5+0.5;
 if(cp.w>0.0){
  vec2 delta=(sunUV-uv)/float(SHAFT_SAMPLES);
  vec2 p=uv+delta*ign(gl_FragCoord.xy);
  float rays=0.0;
  for(int i=0;i<SHAFT_SAMPLES;i++,p+=delta)
   rays+=step(1.0,texture(depthtex0,clamp(p,0.0,1.0)).r);
  rays/=float(SHAFT_SAMPLES);
  float fade=fastSmooth(clamp(1.0-length(sunUV-vec2(0.5))*0.9,0.0,1.0));
  color+=lightCol(sunAngle)*rays*rays*fade*(0.15+sunsetF(sunAngle)*0.25+float(STYLE)*0.1);
 }
 #endif
 outC=vec4(color,1.0);
}
