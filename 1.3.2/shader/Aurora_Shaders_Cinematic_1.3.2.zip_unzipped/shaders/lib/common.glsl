#define fastExp(x) exp2((x)*1.442695)
#define fastSmooth(x) ((x)*(x)*(3.0-2.0*(x)))
#define distSq(v) dot(v,v)
#define luma(c) dot(c,vec3(0.299,0.587,0.114))
float pow5(float x){float x2=x*x;return x2*x2*x;}
float ign(vec2 p){return fract(52.9829189*fract(dot(p,vec2(0.06711056,0.00583715))));}
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float vnoise(vec2 p){vec2 i=floor(p),f=fract(p);f=fastSmooth(f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p,int oct){float v=0.0,a=0.5;for(int i=0;i<10;i++){if(i>=oct)break;v+=vnoise(p)*a;p=p*2.03+17.13;a*=0.5;}return v;}
float dayF(float a){return clamp(cos(a*6.2832)*2.7+0.55,0.0,1.0);}
float nightF(float a){return 1.0-dayF(a);}
float sunsetF(float a){float c=abs(cos(a*6.2832));return fastSmooth(clamp(1.0-c*5.0+0.82,0.0,1.0));}
vec3 lightCol(float a){return mix(mix(vec3(1.0,0.90,0.76),vec3(1.0,0.40,0.16),sunsetF(a)),vec3(0.30,0.40,0.68),nightF(a));}
vec3 distortS(vec3 s){float d=length(s.xy);s.xy/=mix(1.0,d,0.85);return s;}
vec3 acesLite(vec3 c){c=max(c,vec3(0.0));return c/(c+vec3(0.22));}
