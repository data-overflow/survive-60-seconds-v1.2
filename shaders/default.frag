#pragma language glsl1

#define MAX_LIGHTS 300
struct Light {
    vec2 position;
    vec3 diffuse;
    number power;
};

extern Light lights[MAX_LIGHTS];
extern int num_lights;
extern number time;

const number constant = 1.0;
const number linear = 0.09;
const number quadratic = 0.032;

void grayscale(inout vec4 pix, number factor){
	number avg = 0.21 * pix.r + 0.72 * pix.g + 0.07 * pix.b;
	pix.r = pix.r + ((avg - pix.r) * factor);
	pix.g = pix.g + ((avg - pix.g) * factor);
	pix.b = pix.b + ((avg - pix.b) * factor);
}

void filmgrain(inout vec4 pix, vec2 screen_coords, number intensity){	
	float x = (screen_coords.x + 4.0) * (screen_coords.y + 4.0) * (fract(time) * 0.2);
	vec4 grain = intensity * vec4(mod((mod(x, 13) + 1) * (mod(x, 123) + 1), 0.01) - 0.005);	
	pix += grain;
}

void enlighten(inout vec4 pix, vec2 screen_coords){
	vec2 norm_screen = screen_coords / love_ScreenSize.xy;
    vec3 diffuse = vec3(0);
	Light light;
	vec2 norm_pos;
	number distance;
	number attenuation;
	for (int i = 0; i < num_lights; i++) {
        light = lights[i];
        norm_pos = light.position / love_ScreenSize.xy;        
        distance = length(norm_pos - norm_screen) * light.power;
        attenuation = 1.0 / (constant + linear * distance + quadratic * (distance * distance));
        diffuse += light.diffuse * attenuation;
    }
    pix *= vec4(diffuse, 1.0);
}

void applyEffects(inout vec4 pix){
	grayscale(pix, 0.1);	
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
	vec4 pixel = Texel(texture, texture_coords);	
	enlighten(pixel, screen_coords);
	filmgrain(pixel, screen_coords, 16.0);	
	applyEffects(pixel); 
	applyEffects(color);
	
	return pixel * color;
}
