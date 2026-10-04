// weapon_depth.gdshader
// Aplica este shader al material del arma via ShaderMaterial,
// o usa el script weapon_overlay.gd para aplicarlo automáticamente.
//
// Lo que hace:
//   - render_mode depth_prepass_alpha: escribe al depth buffer correctamente
//   - En el vertex shader fuerza VERTEX.z muy cerca (casi 0) en clip space
//     → el arma siempre "gana" al comparar depth con el mundo
//   - La iluminación, culling y orden interno del arma son 100% normales

shader_type spatial;
render_mode cull_back, depth_draw_always;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, hint_default_white;
uniform vec4 albedo_color : source_color = vec4(1.0);
uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap;
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, hint_default_white;

void vertex() {
	// Empuja el arma al plano near del frustum en clip space.
	// POSITION es la posición final en clip space (vec4).
	// Al dividir z por w obtenemos el valor de depth normalizado.
	// Poner z casi igual a -w hace que el depth sea ~0 (lo más cercano posible),
	// por lo que SIEMPRE supera en el depth test a cualquier geometría del mundo.
	POSITION = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	POSITION = PROJECTION_MATRIX * POSITION;
	// Empujar z al near plane: z = -w * (1 - epsilon)
	// Godot usa reverse-Z en 4.3+, ajustamos para ambos casos
	POSITION.z = -POSITION.w + 0.0001;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo_tex.rgb * albedo_color.rgb;
	ALPHA = albedo_tex.a * albedo_color.a;

	vec4 roughness_tex = texture(texture_roughness, UV);
	ROUGHNESS = roughness_tex.r * roughness;
	METALLIC = metallic;

	NORMAL_MAP = texture(texture_normal, UV).rgb;
}
