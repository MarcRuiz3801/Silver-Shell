@tool
extends EditorScript

# COM FER-LO SERVIR:
# 1. Obre aquest fitxer a l'editor de scripts de Godot (Script Editor).
# 2. Selecciona l'escena (al panell "Escena") on hi ha el node arrel
#    que conté tots els meshes (per exemple el node del goblin, o
#    el node arrel del nivell).
# 3. A la barra de dalt del Script Editor: File > Run (o Ctrl+Shift+X).
# 4. Quan acabi, ves a Escena > Desa l'escena (Ctrl+S) perquè els canvis
#    quedin gravats al fitxer .tscn/.tres per sempre.
#
# Com que modifiquem el recurs Material directament (no en fem còpia),
# si dos meshes comparteixen el mateix material només cal processar-lo
# un cop i ja afecta tots els que l'usin.

var _materials_processats: Array[Material] = []


func _run() -> void:
	_materials_processats.clear()

	var arrel := get_editor_interface().get_edited_scene_root()
	if arrel == null:
		push_error("No hi ha cap escena oberta/seleccionada a l'editor.")
		return

	_processar_node(arrel)

	print("Fet. Materials modificats: ", _materials_processats.size())
	print("Recorda desar l'escena (Ctrl+S) perquè els canvis siguin permanents.")


func _processar_node(node: Node) -> void:
	if node is MeshInstance3D:
		_processar_mesh_instance(node as MeshInstance3D)

	for fill in node.get_children():
		_processar_node(fill)


func _processar_mesh_instance(mesh_instance: MeshInstance3D) -> void:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return

	for i in mesh.get_surface_count():
		var material := mesh_instance.get_active_material(i)
		if material == null:
			continue

		if material in _materials_processats:
			continue
		_materials_processats.append(material)

		if material is BaseMaterial3D:
			var base_mat := material as BaseMaterial3D
			base_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			base_mat.specular = 0.0
			# Marquem el recurs com a modificat perquè l'editor sàpiga
			# que cal desar-lo.
			base_mat.set_meta("_edited", true)
		elif material is ShaderMaterial:
			push_warning("'%s' surface %d: ShaderMaterial, no es pot canviar texture_filter/specular automàticament." % [mesh_instance.name, i])

		print("Material modificat a: ", mesh_instance.get_path())
