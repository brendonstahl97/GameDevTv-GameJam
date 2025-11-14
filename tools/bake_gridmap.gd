@tool
extends EditorScript

func _run():
    var gridmap: GridMap = get_scene().get_node("GridMap")
    if not gridmap:
        push_error("GridMap not found!")
        return

    var meshes = gridmap.bake_meshes()  # Returns array of Mesh instances
    if meshes.size() == 0:
        push_error("No meshes baked!")
        return

    # Create one MeshInstance with all baked meshes merged
    var final_mesh := ArrayMesh.new()
    var arrays := []

    for mesh in meshes:
        # Extract each surface and append to final mesh
        for s in mesh.get_surface_count():
            var arr = mesh.surface_get_arrays(s)
            final_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

    # Save mesh
    var save_path = "res://baked_gridmap_mesh.tres"
    ResourceSaver.save(final_mesh, save_path)

    print("Exported GridMap mesh to ", save_path)