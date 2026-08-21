#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
out vec2 uv; out vec4 col;
void main(){
 gl_Position=ftransform();
 gl_Position.xyz=distortS(gl_Position.xyz);
 uv=gl_MultiTexCoord0.xy; col=gl_Color;
}
