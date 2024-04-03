@tool
extends MeshInstance3D


@export var thickness: float = .1 :
	set(value):
		thickness = max(0.0, value)
		if Engine.is_editor_hint():
			update_mesh()
@export var width: float = 1 :
	set(value):
		width = max(thickness * 2.0, value)
		if Engine.is_editor_hint():
			update_mesh()
@export var height: float = 1 :
	set(value):
		height = max(thickness * 2.0, value)
		if Engine.is_editor_hint():
			update_mesh()
@export var corner_radius: float = .2 :
	set(value):
		corner_radius = clampf(value, thickness, min(width, height) / 2.0)
		if Engine.is_editor_hint():
			update_mesh()


func _ready():
	update_mesh()


func update_mesh():
	var corner_radius_3 = Vector3(corner_radius, corner_radius, 0.0)
	var thickness_3 = Vector3(thickness, thickness, 0.0)
	
	mesh.clear_surfaces()
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var corner = Vector3(width / 2.0, height / 2.0, 0.0)
	var mirrors = [
		Vector3(1, 1, 1),
		Vector3(1, -1, 1),
		Vector3(-1, -1, 1),
		Vector3(-1, 1, 1),
	]
	for r in range(3, -1, -1):
		var m = mirrors[r]
		for i in range(0, 9):
			var a = PI * r / 2.0 + ((8 - i) as float / 16.0 * PI)
			var v = Vector3(sin(a), cos(a), 0.0)
			mesh.surface_add_vertex((corner - corner_radius_3) * m + v * corner_radius)
			mesh.surface_add_vertex((corner - corner_radius_3) * m + v * (corner_radius - thickness))
	
	mesh.surface_add_vertex(Vector3(-width / 2.0 + corner_radius, height / 2.0, 0.0))
	mesh.surface_add_vertex(Vector3(-width / 2.0 + corner_radius, height / 2.0 - thickness, 0.0))
	
	mesh.surface_end()
	
	var corner_fill = -corner + thickness_3
	var thickness_diag = thickness * sqrt(2)
	
	for i in range(0, ceil((width + height - thickness_diag * 2.0) / (thickness_diag * 2.0))):
		var offset_0 = i * thickness_diag * 2.0
		var offset_1 = i * thickness_diag * 2.0 + thickness_diag
		
		var p0 = Vector3(0, offset_0, 0)
		var p1 = Vector3(0, offset_1, 0)
		var p2 = Vector3(offset_0, 0, 0)
		var p3 = Vector3(offset_1, 0, 0)
		
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		
		mesh.surface_add_vertex(corner_fill + clamp_diag(p0))
		mesh.surface_add_vertex(corner_fill + clamp_diag(p1))
		mesh.surface_add_vertex(corner_fill + clamp_diag(p2))
		mesh.surface_add_vertex(corner_fill + clamp_diag(p3))
		
		mesh.surface_end()


func clamp_diag(v: Vector3) -> Vector3:
	if v.x > width - thickness * 2:
		var delta = v.x - (width - thickness * 2)
		return v - Vector3(delta, -delta, 0)
	elif v.y > height - thickness * 2:
		var delta = v.y - (height - thickness * 2)
		return v - Vector3(-delta, delta, 0)
	else:
		return v
