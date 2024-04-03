extends MeshInstance3D


func _ready():
	var thickness = .2
	var ps: Array[Vector3] = [
		Vector3(1, -1, 0),
		Vector3(1, 0, 0),
	]
	
	var res = 8.0
	for i in range(1, res + 1):
		var angle = i / res * PI / 2.0
		ps.append(Vector3(cos(angle), sin(angle), 0))
	
	ps.append(Vector3(-1, 1, 0))
	
	# Begin draw.
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	#mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for i in range(len(ps)):
		var p1 = ps[max(0, i - 1)]
		var p2 = ps[i]
		var p3 = ps[min(i + 1, len(ps) - 1)]
		var v1 = (p2 - p1).normalized()
		var v2 = (p3 - p2).normalized()
		var across = ((v1 + v2) / 2.0).normalized().cross(Vector3(0, 0, -1))
		mesh.surface_add_vertex(p2 - across * thickness / 2)
		mesh.surface_add_vertex(p2 + across * thickness / 2)

	# End drawing.
	mesh.surface_end()
