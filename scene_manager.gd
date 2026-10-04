extends Node

var _cache := {}  # clau -> Node (escenes fora de l'arbre, congelades)

func key_of(scene: Node) -> String:
	return scene.get_meta("_key", scene.scene_file_path)

func all_scenes(current: Node) -> Dictionary:
	var d := _cache.duplicate()
	d[key_of(current)] = current
	return d

func change_scene(path: String) -> void:
	_change.call_deferred(path)

func _change(path: String) -> void:
	var cur := get_tree().current_scene
	if cur != null and key_of(cur) == path:
		return
	var new_scene: Node
	if _cache.has(path):
		new_scene = _cache[path]
		_cache.erase(path)
	else:
		new_scene = _make(path, load(path) as PackedScene)
	_swap_to(new_scene, true)

func _make(key: String, packed: PackedScene) -> Node:
	var n := packed.instantiate()
	n.set_meta("_key", key)
	return n

func _swap_to(new_scene: Node, keep_old: bool) -> void:
	var tree := get_tree()
	var old := tree.current_scene
	if old != null:
		tree.root.remove_child(old)   # congelada: no es processa ni es destrueix
		if keep_old:
			_cache[key_of(old)] = old
		else:
			old.queue_free()
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene

func restore(save: SaveGame) -> void:
	for n in _cache.values():
		n.queue_free()
	_cache.clear()
	for key in save.scenes:
		if key != save.current_key:
			_cache[key] = _make(key, save.scenes[key])
	_swap_to(_make(save.current_key, save.scenes[save.current_key]), false)
