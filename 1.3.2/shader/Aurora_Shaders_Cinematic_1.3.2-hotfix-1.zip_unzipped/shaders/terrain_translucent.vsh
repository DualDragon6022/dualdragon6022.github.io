#version 330 compatibility
#include "/settings.glsl"
uniform float frameTimeCounter;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelViewInverse, gbufferModelView;
in vec3 mc_Entity;
in vec4 mc_midTexCoord;
out vec2 uv;
out vec2 lm;
out vec4 col;
out float nl;
out float emit;
out float material;
uniform vec3 shadowLightPosition;
void main(){
 vec4 pos=gbufferModelViewInverse*(gl_ModelViewMatrix*gl_Vertex);
 vec3 wp=pos.xyz+cameraPosition;
#ifdef WAVING_PLANTS
 float isP=float(mc_Entity.x==10001.0); float isL=float(mc_Entity.x==10002.0);
 if(isP+isL>0.5){float t=frameTimeCounter*2.5;float h=clamp((gl_Vertex.y-mc_midTexCoord.y)*6.0,0.0,1.0);float sway=sin(t+wp.x*.75+wp.z*.55)*.075+sin(t*.63+wp.z*1.2)*.035;float sway2=cos(t*.81+wp.x*.4)*.035;pos.xz+=vec2(sway,sway2)*(.25+.75*h);}
#endif
 vec4 v=gbufferModelView*vec4(pos.xyz,1.0); gl_Position=gl_ProjectionMatrix*v; uv=gl_MultiTexCoord0.xy; col=gl_Color; lm=gl_MultiTexCoord1.xy/240.0; vec3 n=normalize(gl_NormalMatrix*gl_Normal); nl=clamp(dot(n,normalize(shadowLightPosition)),0.0,1.0); emit=(mc_Entity.x==10004.0)?.72:((mc_Entity.x==10005.0)?.95:0.0); material=isL*.35+isP*.18;
}
