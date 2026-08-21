#version 330 compatibility
uniform sampler2D gtexture;in vec2 uv;in vec2 lm;in vec4 col;in float nl;in float emit;in float material;layout(location=0) out vec4 c0;layout(location=1) out vec4 c1;layout(location=2) out vec4 c2;
void main(){vec4 c=texture(gtexture,uv)*col;if(c.a<0.1)discard;c0=c;c1=vec4(0.0,0.0,0.0,nl);c2=vec4(lm,emit+material,1.0);}
