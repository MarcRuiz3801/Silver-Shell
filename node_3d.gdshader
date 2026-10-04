shader_type sky;

// Desactiva la niebla para que el espacio se vea nítido
render_mode disable_fog;

// --- TEXTURAS DEL CIELO (ESTRELLAS) ---
uniform sampler2D front_tex : source_color, filter_nearest;
uniform sampler2D back_tex : source_color, filter_nearest;
uniform sampler2D left_tex : source_color, filter_nearest;
uniform sampler2D right_tex : source_color, filter_nearest;
uniform sampler2D up_tex : source_color, filter_nearest;
uniform sampler2D down_tex : source_color, filter_nearest;

// --- TEXTURA DE LA AURORA (LEONARDO.AI) ---
// Usamos filter_linear para ese efecto difuminado "tipo Windows"
uniform sampler2D aurora_tex : source_color, filter_linear, repeat_enable;

group_uniforms Aurora_Settings;
uniform float aurora_scale : hint_range(0.01, 50.0) = 5.0; 
uniform float aurora_aspect_ratio : hint_range(0.1, 2.0) = 0.43; // Tu valor ideal calculado
uniform float aurora_speed : hint_range(0.0, 0.1) = 0.005;      // Movimiento muy lento
uniform float aurora_intensity : hint_range(0.0, 10.0) = 2.0;
uniform vec4 aurora_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float horizon_cutoff : hint_range(0.0, 1.0) = 0.35; 

void sky() {
    vec3 dir = EYEDIR;
    vec3 abs_dir = abs(dir);
    vec2 uv = vec2(0.0);
    vec3 stars_color = vec3(0.0);

    // 1. DIBUJO DE ESTRELLAS (CUBEMAP)
    if (abs_dir.z >= abs_dir.x && abs_dir.z >= abs_dir.y) {
        if (dir.z > 0.0) { uv = vec2(1.0 - (dir.x/dir.z+1.0)*0.5, (dir.y/dir.z+1.0)*0.5); stars_color = texture(back_tex, uv).rgb; }
        else { uv = vec2(1.0 - (dir.x/dir.z-1.0)*0.5, (dir.y/dir.z-1.0)*0.5); stars_color = texture(front_tex, uv).rgb; }
    } else if (abs_dir.x >= abs_dir.y) {
        if (dir.x > 0.0) { uv = vec2((dir.z/dir.x+1.0)*0.5, (dir.y/dir.x+1.0)*0.5); stars_color = texture(right_tex, uv).rgb; }
        else { uv = vec2((dir.z/dir.x-1.0)*0.5, (dir.y/dir.x-1.0)*0.5); stars_color = texture(left_tex, uv).rgb; }
    } else {
        if (dir.y > 0.0) { uv = vec2((dir.x/dir.y+1.0)*0.5, 1.0-(dir.z/dir.y+1.0)*0.5); stars_color = texture(up_tex, uv).rgb; }
        else { uv = vec2(1.0 - (dir.x/dir.y-1.0)*0.5, (dir.z/dir.y-1.0)*0.5); stars_color = texture(down_tex, uv).rgb; }
    }

    // 2. DIBUJO DE AURORA (PLANO RECTO CON DIFUMINADO)
    vec3 aurora_final = vec3(0.0);

    if (dir.y > 0.01) {
        // Coordenadas con corrección de aspecto
        vec2 plane_coords = (vec2(dir.x * aurora_aspect_ratio, dir.z) / dir.y) * aurora_scale;
        
        // APLICAMOS MOVIMIENTO
        // Desplazamiento lento en el tiempo
        plane_coords += TIME * aurora_speed;
        
        // Leemos con el filtro LINEAR ya aplicado arriba
        vec4 aurora_sample = texture(aurora_tex, plane_coords);
        
        // Limpiamos bordes (multiplicar por alfa)
        vec3 color_limpio = aurora_sample.rgb * aurora_sample.a;
        
        // Suavizado hacia el horizonte
        float fade = smoothstep(horizon_cutoff, horizon_cutoff + 0.25, dir.y);
        
        aurora_final = color_limpio * aurora_tint.rgb * aurora_intensity * fade;
    }

    // 3. COLOR FINAL
    COLOR = stars_color + aurora_final;
}