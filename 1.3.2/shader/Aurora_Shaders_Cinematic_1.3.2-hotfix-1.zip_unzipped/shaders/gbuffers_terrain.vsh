#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform float frameTimeCounter; uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse, gbufferModelView;
in vec3 mc_Entity; in vec4 mc_midTexCoord;
out vec2 uv; out vec2 lm; out vec4 col; out float nl; out float emit;
uniform vec3 shadowLightPosition;
void main(){
 vec4 pos=gbufferModelViewInverse*(gl_ModelViewMatrix*gl_Vertex);
 #ifdef WAVING_PLANTS
 float isP=float(mc_Entity.x==10001.0), isL=float(mc_Entity.x==10002.0);
 if(isP+isL>0.5){
  vec3 wp=pos.xyz+cameraPosition; float t=frameTimeCounter*2.4;
  vec2 s=sin(t+wp.xz*vec2(1.7,1.1));
  float tip=float(gl_MultiTexCoord0.t<mc_midTexCoord.t);
  float m=max(isL,tip*isP);
  pos.xz+=s*0.035*m*(0.6+0.4*sin(t*0.31));
 }
 #endif
 gl_Position=gl_ProjectionMatrix*(gbufferModelView*vec4(pos.xyz,1.0));
 uv=gl_MultiTexCoord0.xy; col=gl_Color;
 lm=gl_MultiTexCoord1.xy/240.0;
 vec3 n=normalize(gl_NormalMatrix*gl_Normal);
 nl=clamp(dot(n,normalize(shadowLightPosition)),0.0,1.0);
 emit=(mc_Entity.x==10004.0)?0.5:((mc_Entity.x==10005.0)?1.0:0.0);
}
