#version 330 compatibility
#include "/settings.glsl"
uniform sampler2D gtexture,depthtex1,colortex0;uniform float frameTimeCounter;uniform mat4 gbufferProjection;uniform vec3 skyColor;in vec2 uv;in vec2 lm;in vec4 col;in vec3 vNormal;in vec3 vPos;in float water;layout(location=0) out vec4 c0;layout(location=1) out vec4 c2;
void main(){vec4 c=texture(gtexture,uv)*col;if(c.a<0.01)discard;vec3 n=vNormal;vec3 tint=vec3(0.035,0.16,0.25);if(water>0.5){vec2 wp=vPos.xz+frameTimeCounter*0.5;n=normalize(n+vec3(sin(wp.x*3.1)*0.055,0.0,cos(wp.y*2.7)*0.055));c.rgb=mix(c.rgb,tint,0.46);c.a=0.78;
#ifdef TRANSMITTED_LIGHT
float tr=0.35+0.65*lm.y;c.rgb=mix(c.rgb,c.rgb*tint*2.8,tr*0.22);
#endif
#ifdef REFLECTIONS
vec3 vd=normalize(vPos),rd=reflect(vd,n);float fres=0.025+0.975*pow5(1.0-max(0.0,dot(-vd,n)));vec3 refl=skyColor*(0.75+0.35*float(STYLE));vec3 p=vPos;vec2 huv=vec2(0.0);float stp=0.35;bool hit=false;for(int i=0;i<SSR_STEPS;i++){p+=rd*stp;stp*=1.075;vec4 cp=gbufferProjection*vec4(p,1.0);vec2 suv=cp.xy/cp.w*0.5+0.5;if(clamp(suv,0.0,1.0)!=suv)break;float d=texture(depthtex1,suv).r;if(d>0.0&&d<1.0&&abs(d-cp.z/cp.w*0.5-0.5)<0.012){hit=true;huv=suv;break;}}if(hit)refl=texture(colortex0,huv).rgb;refl*=mix(vec3(1.0),tint*2.0,0.22);c.rgb=mix(c.rgb,refl,fres*0.92);
#endif }
c0=c;c2=vec4(lm,water,1.0);}
