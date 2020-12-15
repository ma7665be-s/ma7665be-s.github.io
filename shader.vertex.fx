precision highp float;

// Attributes
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;
// Uniforms
uniform mat4 worldViewProjection;
uniform mat4 world;
uniform vec3 lightPosition;
uniform vec3 cameraPosition;
//mat4 projectionView = inverse(projection);
// Output
out vec2 tex;
out vec3 n;
out vec3 lp;
out vec3 ld;
out vec3 cp;
out vec3 vd;

void main(void) {

tex = uv;
n = normalize((world*vec4(normal,0.0)).xyz);
vec3 wp = (world*vec4(position,1.0)).xyz;
ld = normalize(lightPosition - wp);
vd = normalize(cameraPosition - wp);
gl_Position = worldViewProjection * vec4(position, 1.0);

}
