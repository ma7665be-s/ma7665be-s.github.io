precision mediump float;

uniform vec2 invRes;
uniform sampler2D depthmap;
uniform sampler2D normalmap;
uniform mat4 projection;
uniform mat4 worldView;

in vec3 n;
in vec3 ld;
in vec3 vd;
in vec2 tex;

float shininess = 1.0;
vec3 ambient = vec3(0.01,0.01,0.01);
vec3 mainDiffuse = vec3(0.55,0.0,0.0);
vec3 secondDiffuse = vec3(0.05,0.0,0.0);
vec3 specular = vec3(0.03,0.03,0.03);
vec3 shadow = vec3(0.0,0.0,0.0);
vec3 outline = vec3(0.9,0.0,0.0);
float frequency = 200.0;


vec3 dotify(vec3 dotColor, vec3 backgroundColor, float radius, float freq){
  vec2 rotate45 = mat2(0.707, -0.707, 0.707, 0.707) * tex;
  vec2 nearest = 2.0*fract(freq * rotate45) - 1.0;
  float dist = length(nearest);
  return mix(dotColor, backgroundColor, step(radius, dist));
}


void main(void) {
  //calculate ambient, diffuse and specular lighting
  float normallightangle = dot(ld,n);
  vec3 dif = shadow;
  if(normallightangle < -0.7){
    dif = dotify(shadow,secondDiffuse,0.7,frequency);
  }else if (normallightangle < 0.0) {
    dif= dotify(secondDiffuse,mainDiffuse,0.7,frequency);
  }else{
    dif = dotify(secondDiffuse,mainDiffuse,0.3,frequency);
  }

  vec3 r = normalize(reflect(ld, n));
  vec3 amb = ambient;
  vec3 spe = specular*pow(step(dot(r,vd), 0.0), shininess);

  //calculate and highlight edges
  vec2 position0 = invRes*gl_FragCoord.xy;
  float scale = 2.0;
  float halfScaleFloor = floor(scale * 0.5);
  float halfScaleCeil = ceil(scale * 0.5);
  vec2 bottomLeft = invRes*vec2(gl_FragCoord.x - halfScaleFloor, gl_FragCoord.y - halfScaleFloor);
  vec2 topRight = invRes*vec2(gl_FragCoord.x + halfScaleCeil, gl_FragCoord.y + halfScaleCeil);
  vec2 bottomRight = invRes*vec2(gl_FragCoord.x + halfScaleCeil, gl_FragCoord.y - halfScaleFloor);
  vec2 topLeft = invRes*vec2(gl_FragCoord.x - halfScaleFloor, gl_FragCoord.y + halfScaleCeil);

  float depth1 = texture(depthmap, bottomLeft).x;
  float depth2 = texture(depthmap, topRight).x;
  float depth3 = texture(depthmap, bottomRight).x;
  float depth4 = texture(depthmap, topLeft).x;
  float depthDistance1 = abs(depth1-depth2);
  float depthDistance2 = abs(depth3-depth4);
  float edgeDepth = sqrt(pow(depthDistance1,2.0) + pow(depthDistance2,2.0));

  vec3 normal1 = texture(normalmap, bottomLeft).xyz;
  vec3 normal2 = texture(normalmap, topRight).xyz;
  vec3 normal3 = texture(normalmap, bottomRight).xyz;
  vec3 normal4 = texture(normalmap, topLeft).xyz;
  vec3 normalDifference1 = normal2 - normal1;
  vec3 normalDifference2 = normal3 - normal4;
  float edgeNormal = sqrt(dot(normalDifference1, normalDifference1) + dot(normalDifference2, normalDifference2));
  vec3 viewPosition = (inverse(projection)*vec4(invRes*gl_FragCoord.xy,0.0,1.0)).xyz;

  vec4 normaltex = texture(normalmap,invRes*gl_FragCoord.xy)*2.0-1.0;
  float NdotV = dot(normaltex.xyz, -viewPosition);
  NdotV = 1.0 - (NdotV+1.0)/2.0;
  float resolutionfactor = sqrt(invRes.y*10.0);
  NdotV = max(NdotV,resolutionfactor);

  if(edgeDepth > (0.0005*NdotV) || edgeNormal > (6.0*NdotV)){
    dif = outline;
  }

  gl_FragColor = vec4(amb + dif + spe, 1.0);
}
