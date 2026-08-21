#version 330 compatibility
uniform sampler2D colortex0;in vec2 uv;/* RENDERTARGETS: 7 */layout(location=0) out vec4 hist;void main(){hist=texture(colortex0,uv);}
