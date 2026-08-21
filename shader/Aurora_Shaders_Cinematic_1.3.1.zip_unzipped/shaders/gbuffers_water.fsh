#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D gtexture,depthtex1,colortex0;uniform float frameTimeCounter;in vec2 uv;in vec2 lm;in vec4 col;in vec3 vNormal;in vec3 vPos;in float water;uniform mat4 gbufferProjection;uniform vec3 skyColor;
/* RENDERTARGETS: 0,2 */
layout(location=0) out vec4 c0;layout(location=1) out vec4 c2;
void main(){vec4 c=texture(gtexture,uv)*col;if(c.a<0.01)discard;vec3 n=vNormal;if(water>0.5){c.rgb=mix(c.rgb,vec3(0.035,0.12,0.22),0.42);c.a=0.78;vec2 wp=vPos.xz+frameTimeCounter*0.5;n=normalize(n+vec3(sin(wp.x*3.1)*0.055,0.0,cos(wp.y*2.7)*0.055));
 #ifdef REFLECTIONS
 vec3 vd=normalize(vPos),rd=reflect(vd,n);float fres=0.02+0.98*pow5(1.0-max(0.0,dot(-vd,n)));vec3 refl=skyColor*(0.8+0.4*float(STYLE));vec3 p=vPos;bool hit=false;vec2 huv=vec2(0);float stp=0.35;for(int i=0;i<SSR_STEPS;i++){p+=rd*stp;stp*=1.10;vec4 cp=gbufferProjection*vec4(p,1.0);vec2 suv=cp.xy/cp.w*0.5+0.5;if(clamp(suv,0.0,1.0)!=suv)break;float d=texture(depthtex1,suv).r;vec4 rp=vec4(suv*2.0-1.0,d*2.0-1.0,1.0);float sceneZ=(gbufferProjection[3][2])/(rp.z+gbufferProjection[2][2]);if(sceneZ>p.z+0.03&&sceneZ<p.z+2.5){hit=true;huv=suv;break;}}if(hit)refl=texture(colortex0,huv).rgb;c.rgb=mix(c.rgb,refl,fres*0.95);
 #endif
 #ifdef WET_SURFACES
 float ca=(vnoise(wp*0.16+frameTimeCounter*0.03)+vnoise(wp*0.32-frameTimeCounter*0.02)*0.5)*0.08;c.rgb+=vec3(0.04,0.12,0.16)*ca;
 #endif
 }c0=c;c2=vec4(lm,0.0,1.0);}
