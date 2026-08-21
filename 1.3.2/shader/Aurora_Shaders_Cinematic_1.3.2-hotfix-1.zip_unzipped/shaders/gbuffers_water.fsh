#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D gtexture, depthtex1, colortex0;
uniform float frameTimeCounter;
in vec2 uv; in vec2 lm; in vec4 col; in vec3 vNormal; in vec3 vPos; in float water;
uniform mat4 gbufferProjection;
uniform vec3 skyColor;
/* RENDERTARGETS: 0,2 */
layout(location=0) out vec4 c0; layout(location=1) out vec4 c2;
void main(){
 vec4 c=texture(gtexture,uv)*col;
 if(c.a<0.01)discard;
 vec3 n=vNormal;
 if(water>0.5){
  c.rgb=mix(c.rgb,vec3(0.05,0.15,0.25),0.5); c.a=0.75;
  vec2 wp=vPos.xz+frameTimeCounter*0.5;
  n=normalize(n+vec3(sin(wp.x*3.1)*0.04,0.0,cos(wp.y*2.7)*0.04));
 }
 #ifdef REFLECTIONS
 if(water>0.5){
  vec3 vd=normalize(vPos);
  vec3 rd=reflect(vd,n);
  float fres=0.02+0.98*pow5(1.0-max(0.0,dot(-vd,n)));
  vec3 refl=skyColor*(0.8+0.4*float(STYLE)); // fallback
  vec3 p=vPos; bool hit=false; vec2 huv=vec2(0);
  float stp=0.5;
  for(int i=0;i<SSR_STEPS;i++){
   p+=rd*stp; stp*=1.15;                    // exponential steps: near detail, far reach
   vec4 cp=gbufferProjection*vec4(p,1.0);
   vec2 suv=cp.xy/cp.w*0.5+0.5;
   if(clamp(suv,0.0,1.0)!=suv)break;
   float d=texture(depthtex1,suv).r;
   vec4 rp=vec4(suv*2.0-1.0,d*2.0-1.0,1.0);
   float sceneZ=(gbufferProjection[3][2])/(rp.z+gbufferProjection[2][2]); // fast linear depth
   if(sceneZ>p.z+0.05&&sceneZ<p.z+2.0){hit=true;huv=suv;break;}
  }
  if(hit)refl=texture(colortex0,huv).rgb;
  c.rgb=mix(c.rgb,refl,fres*0.9);
 }
 #endif
 c0=c; c2=vec4(lm,0.0,1.0);
}
