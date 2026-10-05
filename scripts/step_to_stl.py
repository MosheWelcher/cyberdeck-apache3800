#!/usr/bin/env python3
"""Convert a STEP file to STL so OpenSCAD can import() it.

  python scripts/step_to_stl.py in.step out.stl [max_edge_mm]

Needs gmsh (pip install --user gmsh). Used for the K400 Plus preview model:
  python scripts/step_to_stl.py <Downloads>/Logitech_K400_PLUS.stp ref/local/k400_plus.stl
ref/local/ is git-ignored — third-party models with no redistribution rights
(e.g. GrabCAD) stay on your machine only.
"""
import sys

import gmsh


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    src, dst = sys.argv[1], sys.argv[2]
    max_edge = float(sys.argv[3]) if len(sys.argv) > 3 else 4.0
    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.option.setNumber("Mesh.MeshSizeMax", max_edge)
    gmsh.option.setNumber("Mesh.MeshSizeFromCurvature", 12)   # elements per 2*pi of curvature
    gmsh.option.setNumber("Mesh.Algorithm", 6)                 # Frontal-Delaunay, robust on CAD faces
    gmsh.option.setNumber("Mesh.Binary", 1)
    gmsh.model.occ.importShapes(src)
    gmsh.model.occ.synchronize()
    gmsh.model.mesh.generate(2)
    gmsh.write(dst)
    n = sum(len(t) for t in gmsh.model.mesh.getElements(2)[1])
    gmsh.finalize()
    print(f"wrote {dst} ({n} triangles)")


if __name__ == "__main__":
    main()
