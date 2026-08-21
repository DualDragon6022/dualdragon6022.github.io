#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0,colortex1,colortex2,depthtex0,shadowtex1;uniform mat4 gbufferProjectionInverse,gbufferModelViewInverse,shadowModelView,shadowProjection;uniform vec3 shadowLightPosition,cameraPosition,skyColor;uniform float frameTimeCounter,sunAngle;uniform int isEyeInWater;uniform float heldBlockLightValue;uniform int heldItemId;in vec2 uv;layout(location=0) out vec4 outC;
vec3 toShadow(vec3 wp){vec4 s=shadowProjection*(shadowModelView*vec4(wp,1.0));return distortS(s.xyz)*0.5+0.5;}
vec3 heldColor(){float id=float(heldItemId);float soul=step(0.5,fract(sin(id*0.0173)*91.7));return mix(vec3(1.0,0.47,0.16),vec3(0.28,0.58,1.0),soul);}
void main(){vec3 color=texture(colortex0,uv).rgb;float depth=texture(depthtex0,uv).r;vec4 vp4=gbufferProjectionInverse*vec4(vec3(uv,depth)*2.0-1.0,1.0);vec3 viewPos=vp4.xyz/vp4.w;vec3 worldPos=(gbufferModelViewInverse*vec4(viewPos,1.0)).xyz;float dither=ign(gl_FragCoord.xy);bool sky=depth>=0.99999;float sunset=sunsetF(sunAngle),day=dayF(sunAngle);vec4 g2=texture(colortex2,uv);float blockLight=clamp(g2.x,0.0,1.0);float skyLight=clamp(g2.y,0.0,1.0);
#ifdef DYNAMIC_SHADOWS
if(!sky){vec3 sp=toShadow(worldPos);sp.z-=0.0012;float sh=0.0;for(int i=0;i<8;i++){float a=dither*6.2832+float(i)*0.7854;vec2 o=vec2(cos(a),sin(a))*(1.2+0.7*float(i%3))/float(shadowMapResolution);sh+=step(sp.z,texture(shadowtex1,sp.xy+o).r);}sh=sh/8.0;float NdotL=texture(colortex1,uv).a;float soft=max(0.0,NdotL*sh);vec3 amb=skyColor*(0.30+0.12*day)+vec3(0.035,0.042,0.055);
#ifdef SOFT_BLOCK_LIGHT
float sm=blockLight*blockLight*(3.0-2.0*blockLight);amb+=vec3(1.0,0.86,0.68)*sm*0.55;
#endif
color*=amb+lightCol(sunAngle)*soft*(0.72+0.28*day);
#ifdef COLORED_BLOCKLIGHT
vec3 warm=vec3(1.0,0.42,0.12),cool=vec3(0.25,0.50,1.0);vec3 bc=mix(warm,cool,step(0.55,g2.z));float radius=1.0;vec3 glow=vec3(0.0);for(int i=1;i<=6;i++){float r=float(i)*2.2;vec2 q=vec2(cos(float(i)*2.39996),sin(float(i)*2.39996))*r/vec2(textureSize(colortex0,0));float ld=texture(depthtex0,clamp(uv+q,0.0,1.0)).r;float e=texture(colortex2,clamp(uv+q,0.0,1.0)).z;float same=exp(-abs(ld-depth)*90.0);glow+=bc*e*same/(1.0+float(i)*0.65);}color+=glow*(0.11+0.025*float(LIGHT_SAMPLES));
#endif
}
#endif
#ifdef DYNAMIC_HELD_LIGHT
if(heldBlockLightValue>0.01&&!sky){float hd=length(viewPos);float att=1.0/(1.0+hd*0.055+hd*hd*0.0022);vec3 hc=heldColor();color+=hc*att*clamp(heldBlockLightValue/15.0,0.0,1.0)*1.25;}
#endif
#ifdef VOLUMETRIC_LIGHT
{vec3 endW=sky?normalize(worldPos)*72.0:worldPos;vec3 s0=toShadow(vec3(0.0)),s1=toShadow(endW);vec3 stp=(s1-s0)/float(VL_SAMPLES);vec3 sp=s0+stp*dither;float vl=0.0;for(int i=0;i<VL_SAMPLES;i++,sp+=stp)vl+=step(sp.z-0.001,texture(shadowtex1,sp.xy).r);float mu=dot(normalize(viewPos),normalize(shadowLightPosition));float k=0.72;float ph=(1.0-k*k)/(12.566*(1.0-k*mu)*(1.0-k*mu));color+=lightCol(sunAngle)*(vl/float(VL_SAMPLES))*ph*0.62;}
#endif
#ifdef CUSTOM_FOG
if(!sky){float d2=distSq(worldPos);float fog=clamp(1.0-fastExp(-d2*3.2e-5),0.0,1.0);vec3 fogCol=mix(skyColor*1.05,vec3(1.0,0.48,0.22),sunset)*(0.35+0.65*day);color=mix(color,fogCol,fog*0.65);}
#endif
#ifdef UNDERWATER_FX
if(isEyeInWater==1){float dist=min(length(viewPos),56.0);color*=fastExp(-dist*vec3(0.24,0.075,0.04));color+=vec3(0.0,0.10,0.16)*(1.0-fastExp(-dist*0.10));}
#endif
outC=vec4(color,1.0);}
