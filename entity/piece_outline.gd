@tool
class_name PieceOutline
extends Node3D


var _mesh_instances: Array[MeshInstance3D]


@export var number_of_pieces: int = 0 :
	set(value):
		number_of_pieces = value
		var instance: MeshInstance3D
		if value == 0:
			_resize_instances(0)
		elif value == 1:
			_resize_instances(value)
			instance = _mesh_instances[0]
			instance.mesh = outline_single
			instance.position = Vector3.ZERO
			instance.scale = Vector3.ONE
		#elif value == 2:
			#_resize_instances(value)
			#instance = _mesh_instances[0]
			#instance.mesh = outline_end
			#instance.position = Vector3(-0.05, 0.0, 0.0)
			#instance.scale = Vector3.ONE
			#instance = _mesh_instances[-1]
			#instance.mesh = outline_end
			#instance.position = Vector3(0.35, 0.0, 0.0)
			#instance.scale = Vector3(-1.0, 1.0, -1.0)
		else:
			_resize_instances(maxi(2, value - 1))
			instance = _mesh_instances[0]
			instance.mesh = outline_end
			instance.position = Vector3(-0.05, 0.0, 0.266)
			instance.scale = Vector3.ONE
			instance = _mesh_instances[-1]
			instance.mesh = outline_end
			instance.position = Vector3(-0.25 + value * 0.3, 0.0, 0.266)
			instance.scale = Vector3(-1.0, 1.0, (value % 2) * 2.0 - 1.0)
			for i in range(1, _mesh_instances.size() - 1):
				instance = _mesh_instances[i]
				instance.mesh = outline_middle
				instance.position = Vector3(0.15 + i * 0.3, 0.0, 0.266)
				instance.scale = Vector3((i % 2) * 2.0 - 1.0, 1.0, 1.0)


var outline_single: Mesh = preload("res://model/outline_single.tres")
var outline_end: Mesh = preload("res://model/outline_end.tres")
var outline_middle: Mesh = preload("res://model/outline_middle.tres")


func _resize_instances(new_size: int):
	var instance: MeshInstance3D
	for i in range(_mesh_instances.size(), new_size):
		instance = MeshInstance3D.new()
		_mesh_instances.push_back(instance)
		add_child(instance)
	for i in range(new_size, _mesh_instances.size()):
		instance = _mesh_instances.pop_back()
		instance.queue_free()
