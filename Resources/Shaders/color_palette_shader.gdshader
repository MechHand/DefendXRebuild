shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;

uniform vec4 colors[765]; // Possíveis cores da paleta.
uniform int color_amount = 0; // Número atual de cores da paleta.

void fragment(){
	vec4 px_color = textureLod(screen_texture, SCREEN_UV, 0.0); // Cor do pixel atual.
	
	float min_color_diff = 10000.0;
	vec4 closest_color = vec4(0.0,0.0,0.0,1.0);
	
	for (int i = 0; i < color_amount; ++i){
		float color_dist = distance(colors[i], px_color);
		if(color_dist < min_color_diff){
			min_color_diff = color_dist;
			closest_color = colors[i];
		}
	}
	
	COLOR.rgb = closest_color.rgb;
}