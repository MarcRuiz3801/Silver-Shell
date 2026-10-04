extends Node3D

func _ready():
	for paret_node in get_children():
		# Busca el MeshInstance3D dins de cada paret/columna
		var mesh_instance = paret_node.find_child("*", true, false) as MeshInstance3D
		if mesh_instance:
			afegeix_col·lisió_box(paret_node, mesh_instance)

func afegeix_col·lisió_box(paret_node: Node3D, mesh_instance: MeshInstance3D):
	# Crea StaticBody3D si no en té
	var static_body: StaticBody3D = null
	for fill in paret_node.get_children():
		if fill is StaticBody3D:
			static_body = fill
			break
	
	if not static_body:
		static_body = StaticBody3D.new()
		static_body.name = "StaticBody3D"
		paret_node.add_child(static_body)
		static_body.owner = get_tree().edited_scene_root

	# Evita duplicar CollisionShape3D
	for fill in static_body.get_children():
		if fill is CollisionShape3D:
			return

	# Crea CollisionShape3D amb BoxShape3D
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	var box_shape = BoxShape3D.new()

	# Calcula l'AABB de la mesh per ajustar la caixa
	if mesh_instance.mesh:
		var aabb = mesh_instance.get_aabb()
		box_shape.size = aabb.size
		collision_shape.position = aabb.position + aabb.size * 0.5
	else:
		box_shape.size = Vector3(1, 1, 1)

	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	collision_shape.owner = static_body.get_tree().edited_scene_root
