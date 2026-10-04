extends Node3D

func _ready():
	_aplicar_materials(self)

func _aplicar_materials(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D:
			_modificar_mesh(child)

		_aplicar_materials(child)


func _modificar_mesh(mesh_instance: MeshInstance3D):
	if mesh_instance.mesh == null:
		return

	var surface_count := mesh_instance.mesh.get_surface_count()

	for surface_index in range(surface_count):
		var material_original := mesh_instance.get_active_material(surface_index)

		if material_original == null:
			continue

		# Fer una còpia per no modificar el material compartit original
		var material := material_original.duplicate()

		if material is StandardMaterial3D:
			material.metallic = 0.0
			material.metallic_specular = 0.0
			material.roughness = 1.0
			material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED

			mesh_instance.set_surface_override_material(
				surface_index,
				material
			)
