shader_type sky;
render_mode use_half_res_pass;

group_uniforms day;
	uniform float time_of_day : hint_range(0.0, 1.0, 0.001) = 0.5;
	uniform float sunrise_start : hint_range(0.0, 1.0) = 0.20;
	uniform float day_start     : hint_range(0.0, 1.0) = 0.30;
	uniform float sunset_start  : hint_range(0.0, 1.0) = 0.70;
	uniform float night_start   : hint_range(0.0, 1.0) = 0.80;
	
	uniform vec3 SUN_DIRECTION;

group_uniforms clouds;

	uniform sampler2D cloud_shape_sampler : filter_linear_mipmap_anisotropic, repeat_enable;
	uniform sampler2D cloud_noise_sampler : filter_linear_mipmap_anisotropic, repeat_enable;
	uniform sampler2D cloud_curves;

	uniform int clouds_samples : hint_range(8, 32, 8) = 16;
	uniform int shadow_sample : hint_range(1, 4, 1) = 4;

	uniform float cloud_speed : hint_range(0.0, 199.0, 0.1) = 1.0;
	uniform float clouds_density : hint_range(0.0, 1.0, 0.1) = 0.5;
	uniform float clouds_scale : hint_range(0.5, 1.5, 0.1) = 1.0;
	uniform float clouds_smoothness : hint_range(0.01, 0.1, 0.01) = 0.035;
	uniform float clouds_shadow_intensity : hint_range(0.1, 10.0, 0.1) = 1.0;

group_uniforms high_clouds;

	uniform sampler2D high_clouds_sampler;
	uniform float high_clouds_density : hint_range(0.0, 1.0, 0.05) = 0.0;

group_uniforms sky_morning;

	uniform vec3 sr_top_color : source_color = vec3(0.359, 0.422, 0.842);
	uniform vec3 sr_bottom_color : source_color = vec3(0.466, 0.226, 0.373);
	uniform vec3 sr_sun_scatter : source_color = vec3(0.578, 0.587, 0.803);
	uniform vec3 sr_clouds_light_color : source_color = vec3(0.942, 0.725, 0.778);
	
group_uniforms sky_day;
	
	uniform vec3 top_color : source_color = vec3(0.359, 0.422, 0.842);
	uniform vec3 bottom_color : source_color = vec3(0.466, 0.226, 0.373);
	uniform vec3 sun_scatter : source_color = vec3(0.578, 0.587, 0.803);
	uniform vec3 clouds_light_color : source_color = vec3(0.942, 0.725, 0.778);
	
group_uniforms sky_evening;
	uniform vec3 ss_top_color : source_color = vec3(0.359, 0.422, 0.842);
	uniform vec3 ss_bottom_color : source_color = vec3(0.466, 0.226, 0.373);
	uniform vec3 ss_sun_scatter : source_color = vec3(0.578, 0.587, 0.803);
	uniform vec3 ss_clouds_light_color : source_color = vec3(0.942, 0.725, 0.778);
	
group_uniforms sky_night;
	uniform vec3 night_top_color : source_color = vec3(0.359, 0.422, 0.842);
	uniform vec3 night_bottom_color : source_color = vec3(0.466, 0.226, 0.373);
	uniform vec3 night_sun_scatter : source_color = vec3(0.578, 0.587, 0.803);
	uniform vec3 night_clouds_light_color : source_color = vec3(0.942, 0.725, 0.778);

group_uniforms astro;

	uniform vec3 astro_tint : source_color;
	uniform sampler2D astro_sampler : repeat_disable, filter_linear_mipmap;
	uniform float astro_scale : hint_range(0.1, 10.0, 0.1) = 1.0;
	uniform float astro_intensity : hint_range(1.0, 3.0, 0.1) = 1.0;
	
	uniform float astro_glow_power : hint_range(0.0, 1000.0) = 100.0;
	uniform float astro_glow_intensity : hint_range(0.0, 2000.0) = 1000.0;
	
	uniform sampler2D moon_sampler : repeat_disable, filter_linear_mipmap;

group_uniforms stars;

	uniform float stars_intensity : hint_range(0.0, 5.0, 0.1) = 0.0;
	uniform float stars_size : hint_range(0.0, 2.0, 0.1) = 1.0;
	uniform float stars_amount : hint_range(0.0, 2.0, 0.001) = 0.025;

group_uniforms shooting_stars;

	uniform float shooting_stars_intensity : hint_range(0.0, 10.0, 0.1) = 0.0;
	uniform sampler2D shooting_star_sampler : filter_linear, repeat_disable;
	uniform vec3 shooting_star_tint : source_color = vec3(0.745, 0.426, 0.811);

float rand(float n){return fract(sin(n) * 43758.5453123);}

// Voronoi method credit:
// The MIT License
// Copyright © 2013 Inigo Quilez
// https://www.shadertoy.com/view/ldl3Dl

vec3 hash( vec3 x ){
	x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
			  dot(x,vec3(269.5,183.3,246.1)),
			  dot(x,vec3(113.5,271.9,124.6)));
	return fract(sin(x)*43758.5453123);
}

vec3 voronoi( in vec3 x ){
	vec3 p = floor( x );
	vec3 f = fract( x );
	
	float id = 0.0;
	vec2 res = vec2( 100.0 );
	for( int k=-1; k<=1; k++ )
	for( int j=-1; j<=1; j++ )
	for( int i=-1; i<=1; i++ ) {
		vec3 b = vec3( float(i), float(j), float(k) );
		vec3 r = vec3( b ) - f + hash( p + b );
		float d = dot( r, r );
		if( d < res.x ) {
			id = dot( p+b, vec3(1.0,57.0,113.0 ) );
			res = vec2( d, res.x );
		} else if( d < res.y ) {
			res.y = d;
		}
    }
    return vec3( sqrt( res ), abs(id) );
}

// https://stackoverflow.com/questions/18558910/direction-vector-to-rotation-matrix

mat3 direction_to_matrix(vec3 direction) {
	vec3 x_axis = normalize(cross(vec3(0.0, 1.0, 0.0), direction));
	vec3 y_axis = normalize(cross(direction, x_axis));
	return mat3(vec3(x_axis.x, y_axis.x, direction.x),
				vec3(x_axis.y, y_axis.y, direction.y),
				vec3(x_axis.z, y_axis.z, direction.z));
}

float cloud_density(vec3 p, float progress){
	float t_o = TIME * 0.001 * cloud_speed;
	float t_o_small = TIME * -0.005;
	float noise = texture(cloud_noise_sampler, p.xy * 4.0 + t_o_small).x * 0.1 + 0.9;
	float clouds_shape = texture(cloud_shape_sampler, (p.xy + t_o) * clouds_scale).x;
	float height_curve = texture(cloud_curves, vec2(progress, 0.0)).x;
	float base_density = 1.0 - clouds_density;
	float density = 
	smoothstep(base_density - clouds_smoothness,
	base_density + clouds_smoothness,
	clouds_shape * noise * height_curve
	);
	return density;
}

vec2 cloud_ray_march(vec3 direction, vec3 sun_direction){
	
	float density = 0.0;
	float light = 0.0;
	
	float height = 0.03;
	vec3 sample_point = vec3(0.0, 0.0, 2.0);
	
	int loop_offset = clouds_samples * 3;
	
	for(int i = loop_offset; i < clouds_samples + loop_offset; i++) {
		float progress = float(i) / float(clouds_samples);
		sample_point = direction * height * progress;
		float point_density = cloud_density(sample_point, progress);
		density += point_density;
		
		float point_light = 0.0;
		for(int f = 0; f < shadow_sample; f++){
			float shadow_progress = float(f) / float(shadow_sample);
			vec3 shadow_offset = sun_direction * height * shadow_progress;
			point_light += cloud_density(sample_point + shadow_offset, progress);
		}
		light += point_light;
	}
	return vec2(density, light / float(shadow_sample * clouds_samples));
}

float remap(float t, float a, float b) {
    return clamp((t - a) / (b - a), 0.0, 1.0);
}

void get_phase_weights(float t, out float night_w, out float sunrise_w, out float day_w, out float sunset_w) {
    night_w = 1.0 - remap(t, sunrise_start - 0.05, sunrise_start);
    sunrise_w = remap(t, sunrise_start - 0.05, sunrise_start) * (1.0 - remap(t, day_start, day_start + 0.05));
    day_w = remap(t, day_start, day_start + 0.05) * (1.0 - remap(t, sunset_start, sunset_start + 0.05));
    sunset_w = remap(t, sunset_start, sunset_start + 0.05) * (1.0 - remap(t, night_start, night_start + 0.05));
    night_w += remap(t, night_start, night_start + 0.05);
    
    float total = night_w + sunrise_w + day_w + sunset_w;
    if (total > 0.0) {
        night_w /= total;
        sunrise_w /= total;
        day_w /= total;
        sunset_w /= total;
    }
}


vec3 random_direction(float seed){
	float phi = rand(seed) * PI;
	float costheta = rand(seed + 100.0) * 2.0 - 1.0;
	float theta = acos(costheta);
	return vec3( sin(theta) * cos(phi), (theta) * sin(phi), cos(theta) );
}

float get_shooting_star(vec3 eyedir){
	float shooting_star = 0.0;
	for(int i = 0; i < 4; i++){
		float base_rand = rand(float(i));
		float time = TIME + base_rand * 2.0;
		float duration = 0.5 + base_rand;
		float seed = floor(time / duration) * duration + base_rand;
		float progress = mod(time, duration) / duration;
		float rand_value = rand(seed + 100.0);
		float rand_scale = base_rand * 10.0;
		float a = rand_value * 0.8;
		mat3 angle = mat3(vec3(cos(a), -sin(a), 0.0), vec3(sin(a), cos(a), 0.0), vec3(0.0, 0.0, 1.0));
		vec3 shooting_dir = direction_to_matrix(random_direction(seed)) * angle * eyedir;
		vec2 shooting_uv = ((shooting_dir.xy + vec2(0.0, progress * 0.4)) * (8.0 + rand_scale)) + vec2(0.5);

		float shooting_mask = ceil(
			clamp(shooting_uv.x * (1.0 - shooting_uv.x), 0.0, 1.0) *
			clamp(shooting_uv.y * (1.0 - shooting_uv.y), 0.0, 1.0)
			) * ceil(shooting_dir.z);
			
		shooting_star = clamp(
			shooting_star + texture(shooting_star_sampler, shooting_uv).x
			* sin(progress * PI)
			* shooting_mask * rand_value,
		0.0, 1.0);
	}
	return clamp(shooting_star, 0.0, 1.0);
}


bool is_day(float t, vec3 _SUN_DIRECTION) {
    return dot(normalize(_SUN_DIRECTION), vec3(0.0, 1.0, 0.0)) > 0.0;
}

vec3 get_blended_color(vec3 night, vec3 sunrise, vec3 day, vec3 sunset, float t) {
    float night_w, sunrise_w, day_w, sunset_w;
    get_phase_weights(t, night_w, sunrise_w, day_w, sunset_w);
    return night * night_w + sunrise * sunrise_w + day * day_w + sunset * sunset_w;
}

vec3 add_stars(vec3 sky_color, vec3 _EYEDIR) {
	
	float night_w, sunrise_w, day_w, sunset_w;
	get_phase_weights(time_of_day, night_w, sunrise_w, day_w, sunset_w);

	float star_opacity = night_w; // 1.0 at night, fades out at sunrise/sunset

	if (stars_intensity > 0.0) {
		vec2 stars = voronoi(_EYEDIR * 25.0).xz;
		// Use stars_size to scale the "glow" threshold
		float threshold = stars_amount / stars_size + ((1.0 + sin(TIME + stars.y)) / 2.0) * (0.05 / stars_size);
		// Scale brightness falloff with star size
		float star = smoothstep(threshold, 0.0, stars.x);
		sky_color += (star * stars_intensity * star_opacity);
	}
	return sky_color;
}

vec4 get_astro_color(vec3 dir, vec3 _EYEDIR, sampler2D sampler) {
	vec3 dir_local = direction_to_matrix(dir) * _EYEDIR;
	vec2 uv = (-(dir_local.xy / max(dir_local.z, 0.01)) * astro_scale) + vec2(0.5);
	
	float mask = ceil(
	    clamp(uv.x * (1.0 - uv.x), 0.0, 1.0) *
	    clamp(uv.y * (1.0 - uv.y), 0.0, 1.0)
	) * ceil(dir_local.z);
	
	float rotation_angle = 0.0; // example: slowly rotating over time
	if (SUN_DIRECTION.z < 0.0) {
	    rotation_angle = 3.1415926; // rotate 180 degrees (π radians)
	}

	vec2 centered_uv = uv - vec2(0.5);

	float cos_a = cos(rotation_angle);
	float sin_a = sin(rotation_angle);
	vec2 rotated_uv = vec2(
	    centered_uv.x * cos_a - centered_uv.y * sin_a,
	    centered_uv.x * sin_a + centered_uv.y * cos_a
	);

	rotated_uv += vec2(0.5);
	vec4 color = texture(sampler, rotated_uv) * mask;
	return color;
}

	

void sky() {
	float t = time_of_day;
	float night_w, sunrise_w, day_w, sunset_w;
	get_phase_weights(time_of_day, night_w, sunrise_w, day_w, sunset_w);
	
	float horizon_mask = abs(EYEDIR.y);
	float bottom_mask = smoothstep(0.5, 0.45, SKY_COORDS.y);
	
	vec3 sun_dir = normalize(SUN_DIRECTION);
	vec3 moon_dir = -sun_dir;  // opposite
	
	//if (!is_day(t, SUN_DIRECTION)) {
		//sun_dir = -sun_dir;
		//moon_dir = -moon_dir;
	//}

	vec4 moon_color = get_astro_color(moon_dir, EYEDIR, moon_sampler);
	vec4 sun_color = get_astro_color(sun_dir, EYEDIR, astro_sampler);
	// Sky color
	
	vec3 sky_gradient = mix(
		get_blended_color(night_bottom_color, sr_bottom_color, bottom_color, ss_bottom_color, t), 
		get_blended_color(night_top_color, sr_top_color,top_color, ss_top_color, t), 
		clamp(EYEDIR.y, 0.0, 1.0)
	);
	vec3 sunset_color = get_blended_color(night_sun_scatter, sr_sun_scatter, sun_scatter, ss_sun_scatter, t) * (1.0 - horizon_mask);
	vec3 sky_color = clamp(sky_gradient + sunset_color, 0.0, 1.0);
	
	// Astro glow (sun & moon)
	float angle_to_sun = dot(normalize(EYEDIR), normalize(sun_dir));
	float sun_glow = pow(max(angle_to_sun, 0.0), astro_glow_power); // 1000 = sharp glow falloff
	sky_color += sun_glow * sun_scatter * astro_glow_intensity; // adjust multiplier for glow brightness
	
	// Stars
	sky_color = add_stars(sky_color, EYEDIR);

	// Add shooting stars
	
	if(shooting_stars_intensity > 0.0){
		sky_color += get_shooting_star(EYEDIR) * shooting_stars_intensity * shooting_star_tint * night_w;
	}
	
	// Add astro
	
	// This can be used to limit reflection intensity, if the sun's intensity goes
	// over 1 its HDR and can bleed through shadows badly and muddy shadows
	float working_astro_intensity = astro_intensity;
	if (AT_CUBEMAP_PASS) {
		working_astro_intensity = 1.0; // 0.9 may look better based on your environment!
	}


	//float sun_intensity = day_w + sunrise_w + sunset_w; // sun visible during day phases
	//float moon_intensity = night_w;                     // moon visible at night

	sky_color = mix(sky_color, sun_color.rgb * working_astro_intensity * astro_tint, sun_color.a * 1.0 * bottom_mask);
	sky_color = mix(sky_color, moon_color.rgb * working_astro_intensity * astro_tint, moon_color.a * 1.0 * bottom_mask);

	// Add high clouds
	vec3 clouds_color = get_blended_color(night_clouds_light_color, sr_clouds_light_color, clouds_light_color, ss_clouds_light_color, t);
	
	if(high_clouds_density > 0.0){
		vec2 high_clouds_uv = (EYEDIR.xz / clamp(EYEDIR.y, 0.0, 1.0)) * 0.25 + TIME * 0.001;
		float high_clouds_mask = texture(high_clouds_sampler, high_clouds_uv).x;
		sky_color = mix(sky_color, clouds_color, smoothstep(0.0, 1.0, high_clouds_mask) * horizon_mask * bottom_mask * high_clouds_density);
	}
	
	// clouds
	if (AT_HALF_RES_PASS) {
		vec3 clouds_direction = vec3(EYEDIR.xz / clamp(EYEDIR.y, 0.0, 1.0), 1.0);
		vec2 clouds = EYEDIR.y > 0.0 ? cloud_ray_march(clouds_direction, LIGHT0_DIRECTION) : vec2(0.0);
		
		COLOR = mix(bottom_color, clouds_color, exp(-clouds.y * clouds_shadow_intensity));
		ALPHA = (1.0 - exp(-clouds.x * horizon_mask * bottom_mask * 10.0));
		
	}else{
		COLOR.rgb = mix(sky_color, HALF_RES_COLOR.rgb, HALF_RES_COLOR.a);
	}
}
