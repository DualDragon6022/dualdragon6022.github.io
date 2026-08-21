#version 330 compatibility
uniform sampler2D gtexture;in vec2 uv;in vec4 col;void main(){vec4 c=texture(gtexture,uv)*col;if(c.a<0.1)discard;gl_FragData[0]=c;}
