shader_type spatial;

uniform float time = 0.0;
uniform vec4 deep_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform vec4 shallow_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform vec4 ocean_gradient: hint_color;
uniform float beer_factor = 0.1;
uniform float color_beer_factor = 0.1;
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform vec4 waveA = vec4(0.122,0.164,0.15,10);
uniform vec4 waveB = vec4(0.313,0.621,0.15,10);
uniform vec4 waveC = vec4(1.274,0.891,0.2,25);
uniform vec4 waveD = vec4(1,1,0.05,100);

uniform sampler2D disp_noise1;
uniform sampler2D disp_noise2;
uniform sampler2D normalmap : hint_normal;
uniform sampler2D normalmap2 : hint_normal;
//uniform vec2 normal_direction = vec2(1,0);
uniform float speed : hint_range(-1,1) = 0.0;

const float PI = 3.14159265358979323846264338327950288419716939937510582097494459230781640628;

float generateOffset(float x, float z, float val1, float val2){
	float amountO = 0.1;
	float speedO = 0.1f;
	
	float radiansX = ((mod(x + z * x * val1, amountO) / amountO) + (time * speedO) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amountO) / amountO) + (time * speedO) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return amountO * 0.5 * (sin(radiansZ) + cos(radiansX));
}

vec3 applyDistortion(vec3 vertex){
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2);
	
	return vertex + vec3(xd,yd,zd);
}

vec3 GerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal){
	float steepness = wave.z;
	float wavelength = wave.w;
	float k = 2.0 * PI / wavelength;
	float c = sqrt(9.8/k);
	vec2 d = normalize(wave.xy);
	float f = k * (dot(d, p.xz) - c* time);
	float a = steepness / k;
	
	tangent += vec3(1.0 - d.x * d.x * (steepness * sin(f)),
						d.x * (steepness * cos(f)),
						-d.x * d.y * (steepness * sin(f))
						);
	binormal += vec3(- d.x * d.y * (steepness * sin(f)),
						d.x * (steepness * cos(f)),
						1.0 - d.x * d.x  * (steepness * sin(f))
						);
	
	return vec3(d.x * (a * cos(f)),
				a * sin(f),
				d.y * (a * cos(f))
	);
}

void vertex(){
	vec3 world_vert = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	
	VERTEX = applyDistortion(VERTEX);
	VERTEX += GerstnerWave(waveA, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveB, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveC, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveD, world_vert, tangent, binormal);
	//NORMAL = normalize(cross(binormal,tangent));
	
	
}

void fragment(){
	
	NORMAL = normalize(cross(dFdx(VERTEX),dFdy(VERTEX)));
	vec2 uv_movement = UV*50f - TIME*speed;
	vec2 uv_movement2 = UV*50f + TIME*speed;
	
	//refraction
	vec3 n1 = texture(disp_noise1,UV*4f + time*speed).rgb;
	vec3 n2 = texture(disp_noise2,UV*4f - time*0.2*speed).rgb;
	float sum = (n1.r + n2.r) - 1f;
	
	vec2 disp = vec2(sum*0.05);
	
	METALLIC = 0.6;
	SPECULAR = 0.2;
	ROUGHNESS = 0.3;
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth += VERTEX.z;
	
	vec3 uv_w = (WORLD_MATRIX * vec4(UV.x*500f,1,UV.y*500f, 1.0)).xyz;
	ALBEDO = mix(deep_color.rgb,ocean_gradient.rgb,texture(disp_noise1,uv_w.rb/5000f).rgb*3f-1f);
	
	//beers law
	float beer_depth = exp(-depth * beer_factor);
	float color_depth = exp(-depth * color_beer_factor);
	vec3 alpha = mix(texture(SCREEN_TEXTURE,SCREEN_UV).rgb,shallow_color.rgb,color_depth);
	ALBEDO = mix(ALBEDO,alpha.rgb*5f,color_depth);
	//ALBEDO = deep_color.rgb;
	ALPHA = clamp(1.0 - beer_depth, 0.0, 1.0);
}