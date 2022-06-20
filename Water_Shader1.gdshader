shader_type spatial;

uniform float time = 0.0;
uniform vec4 deep_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform vec4 shallow_color : hint_color = vec4(0.0, 0.2, 1.0, 1.0);
uniform float beer_factor = 0.1;
uniform float color_beer_factor = 0.1;
uniform float amount : hint_range(0.2, 1.5) = 0.8;
uniform vec4 waveA = vec4(1,0,0.5,10);
uniform vec4 waveB = vec4(0,1,0.25,20);
uniform vec4 waveC = vec4(1,1,0.15,10);
uniform vec4 waveD = vec4(1,1,0.15,50);

uniform sampler2D disp_noise1;
uniform sampler2D disp_noise2;
uniform sampler2D normalmap : hint_normal;
uniform sampler2D normalmap2 : hint_normal;
//uniform vec2 normal_direction = vec2(1,0);
uniform float speed : hint_range(-1,1) = 0.0;

float PI(){
	return 3.14159265358979323846264338327950288419716939937510582097494459230781640628;
}

vec3 GerstnerWave(vec4 wave, vec3 p, inout vec3 tangent, inout vec3 binormal){
	float steepness = wave.z;
	float wavelength = wave.w;
	float k = 2.0 * PI() / wavelength;
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
	
	VERTEX += GerstnerWave(waveA, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveB, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveC, world_vert, tangent, binormal);
	VERTEX += GerstnerWave(waveD, world_vert, tangent, binormal);
	NORMAL = normalize(cross(binormal,tangent));
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
	
	//NORMAL += texture(normalmap, uv_movement).rgb*0.5;
	//NORMAL += texture(normalmap2, uv_movement2).rgb*0.5;
	METALLIC = 0.5;
	SPECULAR = 0.9;
	ROUGHNESS = 0.2;
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth = depth * 2.0 - 1.0;
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	depth += VERTEX.z;
	
	//beers law
	float beer_depth = exp(-depth * beer_factor);
	float color_depth = exp(-depth * color_beer_factor);
	//ALBEDO = vec3(depth,depth,depth);
	vec3 alpha = mix(texture(SCREEN_TEXTURE,SCREEN_UV+disp).rgb,shallow_color.rgb,0.1);
	//vec3 alpha = texture(SCREEN_TEXTURE,SCREEN_UV+disp).rgb;
	//ALPHA = clamp(1.0 - beer_depth, 0.0, 1.0);
	//ALBEDO = deep_color.xyz;
	ALBEDO = deep_color.rgb + alpha.rgb*0.01;
}