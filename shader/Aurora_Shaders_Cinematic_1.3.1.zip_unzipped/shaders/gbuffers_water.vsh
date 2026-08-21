#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform float frameTimeCounter;uniform vec3 cameraPosition;uniform mat4 gbufferModelViewInverse,gbufferModelView;in vec3 mc_Entity;out vec2 uv;out vec2 lm;out vec4 col;out vec3 vNormal;out vec3 vPos;out float water;
void main(){vec4 pos=gbufferModelViewInverse*(gl_ModelViewMatrix*gl_Vertex);water=float(mc_Entity.x==10003.0);if(water>0.5){vec3 wp=pos.xyz+cameraPosition;float w=sin(frameTimeCounter*1.7+wp.x*0.7+wp.z*0.9)+0.5*sin(frameTimeCounter*2.3+wp.x*1.3-wp.z*0.8);pos.y+=w*0.035;}vec4 vpos=gbufferModelView*vec4(pos.xyz,1.0);gl_Position=gl_ProjectionMatrix*vpos;vPos=vpos.xyz;uv=gl_MultiTexCoord0.xy;col=gl_Color;lm=gl_MultiTexCoord1.xy/240.0;vNormal=normalize(gl_NormalMatrix*gl_Normal);}
