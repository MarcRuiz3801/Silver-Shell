extends MeshInstance3D

func _ready() -> void:
	if mesh == null:
		print("DEBUG: mesh es null")
		return
	
	var surface_count := mesh.get_surface_count()
	print("DEBUG: superficie count = ", surface_count)
	
	for i in range(surface_count):
		var mat_override = get_surface_override_material(i)
		var mat_active = get_active_material(i)
		var mat_mesh = mesh.surface_get_material(i)
		
		print("--- Superficie %d ---" % i)
		print("  override: ", mat_override)
		print("  active:   ", mat_active)
		print("  en mesh:  ", mat_mesh)
		
		if mat_active is StandardMaterial3D:
			var std := mat_active as StandardMaterial3D
			print("  albedo_texture: ", std.albedo_texture)
			print("  albedo_color:   ", std.albedo_color)
			print("  normal_texture: ", std.normal_texture)
			print("  roughness:      ", std.roughness)
			print("  metallic:       ", std.metallic)
		elif mat_active is ShaderMaterial:
			print("  ES ShaderMaterial")
		else:
			print("  tipo desconocido: ", mat_active.get_class() if mat_active else "null")
