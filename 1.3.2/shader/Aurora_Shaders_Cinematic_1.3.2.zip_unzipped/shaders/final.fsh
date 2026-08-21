#version 330 compatibility
#include "/settings.glsl"
#include "/lib/common.glsl"
uniform sampler2D colortex0,colortex7,depthtex0;uniform mat4 gbufferProjectionInverse,gbufferModelViewInverse,gbufferPreviousModelView,gbufferPreviousProjection;uniform vec3 cameraPosition,previousCameraPosition;in vec2 uv;layout(location=0) out vec4 outC;
void main(){vec3 col=texture(colortex0,uv).rgb;vec2 px=1.0/vec2(textureSize(colortex0,0));
#if ANTIALIASING==2
float d=texture(depthtex0,uv).r;vec4 vp=gbufferProjectionInverse*vec4(vec3(uv,d)*2.0-1.0,1.0);vp/=vp.w;vec3 wp=(gbufferModelViewInverse*vp).xyz+cameraPosition-previousCameraPosition;vec4 pp=gbufferPreviousProjection*(gbufferPreviousModelView*vec4(wp,1.0));vec2 prevUV=pp.xy/pp.w*0.5+0.5;if(clamp(prevUV,0.0,1.0)==prevUV&&d<0.9999){vec3 hist=texture(colortex7,prevUV).rgb;vec3 mn=col,mx=col;for(int x=-1;x<=1;x++)for(int y=-1;y<=1;y++){vec3 c=texelFetch(colortex0,ivec2(gl_FragCoord.xy)+ivec2(x,y),0).rgb;mn=min(mn,c);mx=max(mx,c);}col=mix(col,clamp(hist,mn,mx),0.78);}
#elif ANTIALIASING==1
float l=luma(col),ln=luma(texture(colortex0,uv+vec2(0,px.y)).rgb),ls=luma(texture(colortex0,uv-vec2(0,px.y)).rgb),le=luma(texture(colortex0,uv+vec2(px.x,0)).rgb),lw=luma(texture(colortex0,uv-vec2(px.x,0)).rgb);float mx4=max(l,max(max(ln,ls),max(le,lw))),mn4=min(l,min(min(ln,ls),min(le,lw)));if(mx4-mn4>0.1){vec2 dir=normalize(vec2(ls-ln,lw-le)+1e-6);col=(col+texture(colortex0,uv+dir*px*0.75).rgb+texture(colortex0,uv-dir*px*0.75).rgb)/3.0;}
#endif
#ifdef EMISSIVE_BLOOM
float lum=luma(col);if(lum>0.58){vec3 b=vec3(0.0);float w=0.0;for(int x=-BLOOM_QUALITY;x<=BLOOM_QUALITY;x++)for(int y=-BLOOM_QUALITY;y<=BLOOM_QUALITY;y++){vec3 s=texture(colortex0,uv+vec2(x,y)*px*2.0).rgb;float q=max(luma(s)-0.56,0.0);b+=s*q;w+=q;}if(w>0.001)col+=b/w*(0.012+0.008*float(BLOOM_QUALITY));}
#endif
col=max(col,vec3(0.0));col=col/(col+vec3(0.16));col=pow(col,vec3(0.92));col=mix(col,col*vec3(1.025,1.015,0.99),0.35);outC=vec4(clamp(col,0.0,1.0),1.0);}
